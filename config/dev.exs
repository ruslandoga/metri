import Config

config :metri, Metri.Repo,
  pool_size: 5,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  database: "metrics.db"
