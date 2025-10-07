defmodule StackoverflowClone.LLMAdapters.Ollama do
  @moduledoc """
  Ollama adapter for re-ranking Stack Overflow answers using local models.
  Supports models like llama3, mistral, codellama, etc.
  """

  @behaviour StackoverflowClone.LLMAdapters.Behaviour

  @default_url "http://localhost:11434"
  @timeout 300_000  # 5 minutes - much more reasonable for local LLMs
  @recv_timeout 300_000

  @impl true
  def rerank(question_text, answers) do
    ollama_url = System.get_env("OLLAMA_URL") || @default_url
    model_name = System.get_env("OLLAMA_MODEL") || "llama3"
    
    # Build minimal prompt
    prompt = build_minimal_prompt(question_text, answers)
    
    request_body = %{
      model: model_name,
      prompt: prompt,
      stream: false,
      options: %{
        temperature: 0.1,  # Low temperature for consistent JSON
        num_predict: 500   # Limit response length
      }
    }

    headers = [{"Content-Type", "application/json"}]
    url = "#{ollama_url}/api/generate"


    # Use both timeout and recv_timeout
    http_options = [
      timeout: @timeout,
      recv_timeout: @recv_timeout
    ]

    case HTTPoison.post(url, Jason.encode!(request_body), headers, http_options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_ollama_response(body, answers)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, {:http_error, status_code, body}}

      {:error, %HTTPoison.Error{reason: :timeout}} ->
        {:error, :timeout}

      {:error, %HTTPoison.Error{reason: :econnrefused}} ->
        {:error, :connection_refused}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Verify Ollama is ready with the model
  def verify_model_ready do
    ollama_url = System.get_env("OLLAMA_URL") || @default_url
    model_name = System.get_env("OLLAMA_MODEL") || "llama3"
    
    # First check if Ollama is running
    case check_ollama_running(ollama_url) do
      {:ok, _} ->
        # Then check if model is available
        check_model_available(ollama_url, model_name)
      
      error ->
        error
    end
  end

  defp check_ollama_running(ollama_url) do
    case HTTPoison.get("#{ollama_url}/api/tags", [], timeout: 5_000) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        {:ok, "Ollama is running"}
      
      {:error, %HTTPoison.Error{reason: :econnrefused}} ->
        {:error, "Ollama is not running. Start it with: ollama serve"}
      
      {:error, reason} ->
        {:error, "Cannot reach Ollama: #{inspect(reason)}"}
    end
  end

  defp check_model_available(ollama_url, model_name) do
    case HTTPoison.get("#{ollama_url}/api/tags", [], timeout: 5_000) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"models" => models}} ->
            model_names = Enum.map(models, & &1["name"])
            
            if Enum.any?(model_names, &String.contains?(&1, model_name)) do
              {:ok, "Model #{model_name} is available"}
            else
              {:error, "Model #{model_name} not found. Available: #{inspect(model_names)}. Pull it with: ollama pull #{model_name}"}
            end
          
          _ ->
            {:error, "Cannot parse models list"}
        end
      
      {:error, reason} ->
        {:error, "Cannot check models: #{inspect(reason)}"}
    end
  end

  # Extremely minimal prompt - only rank top 3 answers
  defp build_minimal_prompt(question_text, answers) do
    # Limit to 3 answers max, 80 chars each
    limited_answers = answers
    |> Enum.take(3)
    |> Enum.with_index(1)
    |> Enum.map(fn {answer, idx} ->
      body = sanitize_and_limit(answer["body"], 80)
      id = answer["answer_id"] || answer["id"] || idx
      ~s(#{idx}. ID:#{id} "#{body}")
    end)
    |> Enum.join("\n")

    q_text = String.slice(question_text, 0, 100)

    """
    Rank answers 1-10 for: "#{q_text}"

    #{limited_answers}

    JSON format: {"ranked":[{"answer_id":"123","score":8.5,"reason":"clear"}]}
    """
  end

  defp sanitize_and_limit(html, max_length) when is_binary(html) do
    html
    |> Floki.parse_document!()
    |> Floki.text()
    |> String.trim()
    |> String.slice(0, max_length)
    |> String.replace(~r/\s+/, " ")
  end

  defp sanitize_and_limit(_, _), do: ""

  defp parse_ollama_response(body, original_answers) do
    case Jason.decode(body) do
      {:ok, %{"response" => content}} ->
        extract_ranking_json(content, original_answers)

      {:ok, %{"error" => error_msg}} ->
        {:error, {:ollama_error, error_msg}}

      {:ok, response} ->
        {:error, :invalid_response_format}

      {:error, decode_error} ->
        {:error, :json_decode_error}
    end
  end

  defp extract_ranking_json(content, original_answers) do
    # Try to find JSON object in the response
    case Regex.run(~r/\{[^}]*"ranked"[^}]*\[[^\]]*\][^}]*\}/s, content) do
      [json_string] ->
        case Jason.decode(json_string) do
          {:ok, %{"ranked" => ranked_list}} when is_list(ranked_list) ->
            {:ok, ranked_list}

          {:ok, parsed} ->
            {:error, :invalid_json_structure}

          {:error, _} ->
            {:error, :json_decode_error}
        end

      nil ->
        # Return fallback ranking
        fallback_ranking(original_answers)
    end
  end

  defp fallback_ranking(answers) do
    ranked = answers
    |> Enum.take(3)
    |> Enum.with_index(1)
    |> Enum.map(fn {answer, idx} ->
      %{
        "answer_id" => answer["answer_id"] || answer["id"] || idx,
        "score" => 5.0,
        "reason" => "Fallback ranking (Ollama timeout)"
      }
    end)
    
    {:ok, ranked}
  end
end