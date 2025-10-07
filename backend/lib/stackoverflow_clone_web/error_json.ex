defmodule StackoverflowCloneWeb.ErrorJSON do
  @moduledoc """
  This module is invoked by your endpoint in case of errors on JSON requests.

  See config/config.exs.
  """

  def error(%{status: status}) do
    %{errors: %{detail: status_message(status)}}
  end

  defp status_message(400), do: "Bad Request"
  defp status_message(401), do: "Unauthorized"
  defp status_message(403), do: "Forbidden"
  defp status_message(404), do: "Not Found"
  defp status_message(422), do: "Unprocessable Entity"
  defp status_message(500), do: "Internal Server Error"
  defp status_message(_), do: "Unknown Error"
end
