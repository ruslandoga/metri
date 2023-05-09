defmodule Metri.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Metri.Repo,
      %{id: :cache, start: {__MODULE__, :start_cache, []}}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Metri.Supervisor)
  end

  def start_cache do
    import Ecto.Query

    :ets.new(:metric_to_series, [:named_table, :public])
    :ets.new(:series_to_metric, [:named_table, :public])
    max_series_id_ref = :atomics.new(1, signed: false)
    :persistent_term.put(:max_series_id, max_series_id_ref)

    Metri.Repo.transaction(fn ->
      "label_to_series"
      |> select([ls], {ls.name, ls.value, ls.series_id})
      |> Metri.Repo.all()
      |> Enum.group_by(
        fn {_name, _value, series_id} -> series_id end,
        fn {name, value, _series_id} -> {name, value} end
      )
      |> Enum.each(fn {series_id, labels} ->
        labels = Enum.sort_by(labels, fn {name, _value} -> name end)
        :ets.insert(:metric_to_series, {labels, series_id})
        :ets.insert(:series_to_metric, {series_id, labels})
      end)

      max_series_id =
        "label_to_series"
        |> select([ls], max(ls.series_id))
        |> Metri.Repo.one()

      :atomics.put(max_series_id_ref, 1, max_series_id || 0)
    end)

    :ignore
  end
end
