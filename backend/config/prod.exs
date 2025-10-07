import Config

config :stackoverflow_clone, StackoverflowClone.Repo,
  url: System.get_env("DATABASE_URL") ||
    raise("environment variable DATABASE_URL is missing."),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise("environment variable SECRET_KEY_BASE is missing.")

host = System.get_env("PHX_HOST") || "example.com"
port = String.to_integer(System.get_env("PORT") || "4000")

config :stackoverflow_clone, StackoverflowCloneWeb.Endpoint,
  url: [host: host, port: 443, scheme: "https"],
  http: [
    ip: {0, 0, 0, 0, 0, 0, 0, 0},
    port: port
  ],
  secret_key_base: secret_key_base

config :stackoverflow_clone, StackoverflowClone.Repo,
  ssl: true,
  verify_ssl_name: true,
  check_origin: ["https://#{host}"]

config :logger, level: :info

import_config "prod.secret.exs"
