defmodule Metri do
  @moduledoc "Basic metrics in SQLite"
  import Ecto.Query

  @doc """
  Examples:

      # http_requests_total{method="post",code="200"} 1027 1395066363000
      # http_requests_total{method="post",code="400"}    3 1395066363000
      insert_metrics([
        [_labels = [{"__name__", "http_requests_total"}, {"method", "post"}, {"code", "200"}], _value = 1027, _timestamp = 1395066363000],
        [_labels = [{"__name__", "http_requests_total"}, {"method", "post"}, {"code", "400"}], _value = 3, _timestamp = 1395066363000]
      ])
      :ok

  """
  def insert_metrics(metrics) do
    Metri.Repo.transaction(fn ->
      Enum.each(metrics, fn [labels, value, timestamp] ->
        labels = Enum.sort_by(labels, fn {name, _value} -> name end)
        series_id = series_id(labels) || create_series_id(labels)
        insert_metric(series_id, value, timestamp || System.system_time(:millisecond))
      end)
    end)
  end

  defp insert_metric(series_id, value, timestamp) do
    Metri.Repo.insert_all("samples", [[series_id: series_id, value: value, timestamp: timestamp]])
  end

  defp series_id(labels) do
    case :ets.lookup(:metric_to_series, labels) do
      [{_, series_id}] -> series_id
      [] -> nil
    end
  end

  defp create_series_id(labels) do
    series_id = :atomics.add_get(:persistent_term.get(:max_series_id), 1, 1)

    Metri.Repo.insert_all(
      "label_to_series",
      Enum.map(labels, fn {name, value} -> [name: name, value: value, series_id: series_id] end)
    )

    series_id
  end
end
