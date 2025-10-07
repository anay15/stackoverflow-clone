defmodule StackoverflowCloneWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :stackoverflow_clone

  @session_options [
    store: :cookie,
    key: "_stackoverflow_clone_key",
    signing_salt: "your_signing_salt_here"
  ]

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug StackoverflowCloneWeb.Router
end
