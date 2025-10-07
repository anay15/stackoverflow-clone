defmodule StackoverflowClone.LLMAdapters.LocalLLM do
  @moduledoc """
  Local LLM adapter for re-ranking Stack Overflow answers.
  """

  @behaviour StackoverflowClone.LLMAdapters.Behaviour

  @timeout 30_000

  @impl true
  def rerank(question_text, answers) do
    url = System.get_env("LOCAL_LLM_URL")

    request_body = %{
      question: question_text,
      answers: build_answers_for_local_llm(answers)
    }

    headers = [{"Content-Type", "application/json"}]

    case HTTPoison.post(url, Jason.encode!(request_body), headers, timeout: @timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"ranked" => ranked_list}} ->
            {:ok, ranked_list}

          {:ok, _} ->
            {:error, :invalid_response_format}

          {:error, _} ->
            {:error, :json_decode_error}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, {:http_error, status_code, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp build_answers_for_local_llm(answers) do
    Enum.map(answers, fn answer ->
      %{
        "id" => answer["answer_id"],
        "body" => sanitize_html(answer["body"]),
        "score" => answer["score"],
        "is_accepted" => answer["is_accepted"]
      }
    end)
  end

  defp sanitize_html(html) when is_binary(html) do
    html
    |> Floki.parse_document!()
    |> Floki.text()
    |> String.slice(0, 500)
  end

  defp sanitize_html(_), do: ""
end
