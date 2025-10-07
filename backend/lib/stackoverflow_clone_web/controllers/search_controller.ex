defmodule StackoverflowCloneWeb.SearchController do
  use StackoverflowCloneWeb, :controller

  alias StackoverflowClone.SearchContext

  def search(conn, %{"query" => query}) when is_binary(query) and byte_size(query) > 0 do
    case SearchContext.search_stackoverflow(query) do
      {:ok, answers} ->
        json(conn, %{
          success: true,
          query: query,
          answers: answers,
          total: length(answers)
        })

      {:error, :no_results} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          success: false,
          error: "No results found for your query",
          suggestions: [
            "Try different keywords",
            "Check your spelling",
            "Use more general terms"
          ]
        })

      {:error, {:http_error, status_code}} ->
        conn
        |> put_status(:service_unavailable)
        |> json(%{
          success: false,
          error: "Stack Exchange API error",
          details: "HTTP #{status_code}"
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          success: false,
          error: "Search failed",
          details: inspect(reason)
        })
    end
  end

  def search(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      success: false,
      error: "Query parameter is required and must be a non-empty string"
    })
  end

  def rerank(conn, %{"question" => question_text, "answers" => answers}) do
    case SearchContext.rerank_answers(question_text, answers) do
      {:ok, ranked_answers} ->
        json(conn, %{
          success: true,
          ranked_answers: ranked_answers
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          success: false,
          error: "Re-ranking failed",
          details: inspect(reason)
        })
    end
  end

  def rerank(conn, _params) do
    conn
    |> put_status(:bad_request)
    |> json(%{
      success: false,
      error: "Both 'question' and 'answers' parameters are required"
    })
  end

  def recent(conn, _params) do
    recent_searches = SearchContext.get_recent_searches()
    json(conn, %{
      success: true,
      recent_searches: recent_searches
    })
  end

  def llm_status(conn, _params) do
    has_ollama = System.get_env("OLLAMA_URL") != nil
    ollama_url = System.get_env("OLLAMA_URL") || "http://localhost:11434"
    ollama_model = System.get_env("OLLAMA_MODEL") || "llama3"

    json(conn, %{
      success: true,
      llm_available: has_ollama,
      ollama_configured: has_ollama,
      ollama_url: ollama_url,
      ollama_model: ollama_model,
      message: (if has_ollama, do: "Ollama LLM ranking available", else: "No Ollama configured - using fallback ranking")
    })
  end

  def options(conn, _params) do
    conn
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "content-type, authorization")
    |> put_resp_header("access-control-max-age", "86400")
    |> send_resp(200, "")
  end
end
