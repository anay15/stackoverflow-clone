import Config

# Load environment variables from .env file
# Dotenv.load()

config :stackoverflow_clone,
  ecto_repos: [StackoverflowClone.Repo]

config :stackoverflow_clone, StackoverflowCloneWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: StackoverflowCloneWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: StackoverflowClone.PubSub,
  live_view: [signing_salt: "your_signing_salt_here"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
