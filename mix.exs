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
      {:benchee, "~> 1.1", only: [:bench]}
    ]
  end
end
