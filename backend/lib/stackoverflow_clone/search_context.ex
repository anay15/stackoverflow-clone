defmodule StackoverflowClone.SearchContext do
  @moduledoc """
  The SearchContext module handles all search-related operations including
  Stack Exchange API integration, recent searches caching, and LLM re-ranking.
  """

  import Ecto.Query, warn: false
  alias StackoverflowClone.Repo
  alias StackoverflowClone.Search

  @stackexchange_base_url "https://api.stackexchange.com/2.3"
  @user_agent "StackOverflow-Clone/1.0"

  @doc """
  Searches Stack Overflow for questions matching the query and returns answers.
  Also saves the search to recent searches.
  """
  def search_stackoverflow(query) do
    with {:ok, _} <- save_recent_search(query),
         {:ok, questions} <- fetch_questions(query),
         {:ok, answers} <- fetch_answers_for_questions(questions) do
      {:ok, answers}
    else
      error -> error
    end
  end

  @doc """
  Re-ranks answers using LLM or fallback heuristic.
  """
  def rerank_answers(question_text, answers) do
    case get_llm_adapter() do
      {:ok, adapter} ->
        IO.inspect("Using LLM adapter: #{inspect(adapter)}")
        case adapter.rerank(question_text, answers) do
          {:ok, ranked_answers} -> 
            IO.inspect("LLM ranking successful")
            {:ok, ranked_answers}
          {:error, reason} -> 
            IO.inspect("LLM ranking failed: #{inspect(reason)}")
            {:ok, fallback_ranking(answers)}
        end

      {:error, reason} ->
        IO.inspect("No LLM adapter available: #{inspect(reason)}")
        {:ok, fallback_ranking(answers)}
    end
  end

  @doc """
  Gets the most recent 5 searches.
  """
  def get_recent_searches do
    Search
    |> order_by(desc: :inserted_at)
    |> limit(5)
    |> Repo.all()
  end

  defp save_recent_search(query) do
    %Search{}
    |> Search.changeset(%{query: query})
    |> Repo.insert()
    |> case do
      {:ok, _search} ->
        # Keep only the 5 most recent searches
        cleanup_old_searches()
        {:ok, :saved}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp cleanup_old_searches do
    # Get the 5th most recent search
    fifth_recent = Search |> order_by(desc: :inserted_at) |> offset(4) |> limit(1) |> Repo.one()

    if fifth_recent do
      # Delete all searches older than the 5th most recent
      Search
      |> where([s], s.inserted_at < ^fifth_recent.inserted_at)
      |> Repo.delete_all()
    end
  end

  defp fetch_questions(query) do
    api_key = System.get_env("STACKEXCHANGE_KEY")
    url = build_search_url(query, api_key)

    case HTTPoison.get(url, [{"User-Agent", @user_agent}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"items" => items}} when length(items) > 0 ->
            {:ok, items}

          {:ok, %{"items" => []}} ->
            {:error, :no_results}

          {:error, _} ->
            {:error, :invalid_response}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, {:http_error, status_code}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_answers_for_questions(questions) do
    # Get the most relevant question (first in the list)
    top_question = List.first(questions)
    question_id = top_question["question_id"]

    api_key = System.get_env("STACKEXCHANGE_KEY")
    url = build_answers_url(question_id, api_key)

    case HTTPoison.get(url, [{"User-Agent", @user_agent}]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"items" => answers}} ->
            # Add question context to each answer
            answers_with_context =
              Enum.map(answers, fn answer ->
                Map.put(answer, "question", top_question)
              end)

            {:ok, answers_with_context}

          {:error, _} ->
            {:error, :invalid_response}
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, {:http_error, status_code}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_search_url(query, api_key) do
    base_params = [
      "order=desc",
      "sort=relevance",
      "q=#{URI.encode(query)}",
      "site=stackoverflow",
      "pagesize=1",
      "filter=withbody"
    ]

    params = if api_key, do: base_params ++ ["key=#{api_key}"], else: base_params
    "#{@stackexchange_base_url}/search/advanced?#{Enum.join(params, "&")}"
  end

  defp build_answers_url(question_id, api_key) do
    base_params = [
      "order=desc",
      "sort=votes",
      "site=stackoverflow",
      "pagesize=10",
      "filter=withbody"
    ]

    params = if api_key, do: base_params ++ ["key=#{api_key}"], else: base_params
    "#{@stackexchange_base_url}/questions/#{question_id}/answers?#{Enum.join(params, "&")}"
  end

  defp get_llm_adapter do
    ollama_url = System.get_env("OLLAMA_URL")
    
    if ollama_url do
      {:ok, StackoverflowClone.LLMAdapters.Ollama}
    else
      {:error, :no_llm_configured}
    end
  end

  defp fallback_ranking(answers) do
    answers
    |> Enum.sort_by(fn answer ->
      # Sort by: accepted first, then by score (desc), then by creation_date (desc)
      accepted_score = if answer["is_accepted"], do: 1, else: 0
      score = answer["score"] || 0
      creation_date = answer["creation_date"] || 0

      {-accepted_score, -score, -creation_date}
    end)
    |> Enum.with_index(1)
    |> Enum.map(fn {answer, rank} ->
      %{
        "answer_id" => answer["answer_id"],
        "score" => 10.0 - (rank - 1) * 0.5,
        "reason" => "Fallback ranking: #{if answer["is_accepted"], do: "accepted answer", else: "sorted by score"}"
      }
    end)
  end
end
