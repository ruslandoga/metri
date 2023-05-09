import Config

config :metri, ecto_repos: [Metri.Repo]

config :metri, Metri.Repo,
  # https://litestream.io/tips/#disable-autocheckpoints-for-high-write-load-servers
  wal_auto_check_point: 0,
  # https://litestream.io/tips/#busy-timeout
  busy_timeout: 5000,
  cache_size: -2000

import_config "#{config_env()}.exs"
