defmodule Metri.MixProject do
  use Mix.Project

  def project do
    [
      app: :metri,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: releases(),
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

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sqlite3, "~> 0.10.1"},
      {:jason, "~> 1.4"},
      {:benchee, "~> 1.1", only: [:bench]},
      {:finch, "~> 0.16.0"}
    ]
  end

  defp releases do
    [metri: [include_executables_for: [:unix]]]
  end
end
