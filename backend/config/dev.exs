import Config

config :stackoverflow_clone, StackoverflowClone.Repo,
  # Read connection settings from environment variables, falling back to local defaults.
  # If you set DATABASE_USERNAME in your shell, it will override "anaynayak".
  username: System.get_env("DATABASE_USERNAME") || "anaynayak",
  # If you set DATABASE_PASSWORD in your shell, it will override "".
  password: System.get_env("DATABASE_PASSWORD") || "",
  # Defaults to localhost unless DATABASE_HOSTNAME is set.
  hostname: System.get_env("DATABASE_HOSTNAME") || "localhost",
  # Defaults to stackoverflow_clone_dev unless DATABASE_NAME is set.
  database: System.get_env("DATABASE_NAME") || "stackoverflow_clone_dev",

  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :stackoverflow_clone, StackoverflowCloneWeb.Endpoint,
  http: [
    ip: {127, 0, 0, 1}, 
    port: String.to_integer(System.get_env("PORT") || "4000"),
    # Only use valid Phoenix HTTP options
    timeout: 60_000  # 1 minute - this is the only valid timeout option
  ],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "your_secret_key_base_here",
  watchers: []

config :stackoverflow_clone, StackoverflowCloneWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/stackoverflow_clone_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime