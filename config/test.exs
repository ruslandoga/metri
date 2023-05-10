import Config

config :metri, Metri.Repo,
  database: ":memory:",
  pool_size: 4,
  pool: Ecto.Adapters.SQL.Sandbox

config :logger, level: :warning
