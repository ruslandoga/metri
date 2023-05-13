import Config

config :metri, ecto_repos: [Metri.Repo]

config :metri, Metri.Repo,
  # https://litestream.io/tips/#busy-timeout
  busy_timeout: 5000,
  cache_size: -2000

config :metri, MetriWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: MetriWeb.ErrorHTML, json: MetriWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Metri.PubSub,
  live_view: [signing_salt: "DX/4UIEw"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
