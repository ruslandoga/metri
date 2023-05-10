import Config

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
