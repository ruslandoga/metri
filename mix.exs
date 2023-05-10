defmodule Metri.MixProject do
  use Mix.Project

  def project do
    [
      app: :metri,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Metri.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sqlite3, "~> 0.10.1"},
      {:benchee, "~> 1.1", only: [:bench]},
      {:nimble_csv, "~> 1.2", only: [:bench]},
      {:jason, "~> 1.4", only: [:bench]},
      {:nimble_lz4, "~> 0.1.2", only: [:bench]},
      {:educkdb, "~> 0.6.0", only: [:bench]},
      {:duckdbex, "~> 0.2.3", only: [:bench]},
      {:exduckdb, "~> 0.9.0", only: [:bench]}
    ]
  end
end
