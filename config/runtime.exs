import Config

if System.get_env("PHX_SERVER") do
  config :metri, MetriWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      environment variable DATABASE_PATH is missing.
      For example: /etc/metri/metrics.db
      """

  config :metri, Metri.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  if System.get_env("LITESTREAM") do
    # https://litestream.io/tips/#disable-autocheckpoints-for-high-write-load-servers
    config :metri, Metri.Repo, wal_auto_check_point: 0
  end

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :metri, MetriWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/plug_cowboy/Plug.Cowboy.html
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end

if config_env() == :test do
  migrations = Migrator.migrations(Metri.Repo)

  config :metri, Metri.Repo,
    after_connect: fn conn ->
      Migrator.prepare(conn: conn, repo: Metri.Repo)

      Enum.each(migrations, fn {version, mod} ->
        Ecto.Migration.Runner.run(Migrator, [], version, mod, :forward, :change, :up, [])
      end)
    end
end
