defmodule StackoverflowClone.LLMAdapters.Behaviour do
  @moduledoc """
  Behaviour for LLM adapters that can re-rank Stack Overflow answers.
  """

  @callback rerank(question_text :: String.t(), answers :: list()) ::
              {:ok, ranked_answers :: list()} | {:error, reason :: any()}
end
