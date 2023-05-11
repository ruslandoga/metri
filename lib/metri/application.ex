defmodule Metri.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Metri.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Metri.Supervisor)
  end
end
