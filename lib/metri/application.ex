defmodule Metri.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Metri.Repo,
      {Phoenix.PubSub, name: Metri.PubSub},
      {Finch, name: Metri.Finch},
      MetriWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Metri.Supervisor)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MetriWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
