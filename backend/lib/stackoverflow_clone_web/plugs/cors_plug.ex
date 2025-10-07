defmodule StackoverflowCloneWeb.Plugs.CORSPlug do
  @moduledoc """
  Simple CORS plug for development.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, opts) do
    origin = get_origin(conn, opts)

    conn
    |> put_resp_header("access-control-allow-origin", origin)
    |> put_resp_header("access-control-allow-methods", "GET, POST, PUT, DELETE, OPTIONS")
    |> put_resp_header("access-control-allow-headers", "content-type, authorization")
    |> put_resp_header("access-control-allow-credentials", "true")
    |> handle_options()
  end

  defp get_origin(conn, opts) do
    request_origin = get_req_header(conn, "origin") |> List.first()

    if request_origin in (opts[:origin] || []) do
      request_origin
    else
      "*"
    end
  end

  defp handle_options(%{method: "OPTIONS"} = conn) do
    conn
    |> send_resp(200, "")
    |> halt()
  end

  defp handle_options(conn), do: conn
end
