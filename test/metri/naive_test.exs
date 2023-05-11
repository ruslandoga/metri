defmodule Metri.NaiveTest do
  use Metri.DataCase, async: true

  @samples [
    # http_requests_total{method="post",code="200"} 1027 1395066363000
    # http_requests_total{method="post",code="400"}    3 1395066363000
    # etc.
    %{
      name: "http_requests_total",
      labels: %{"method" => "post", "code" => "200"},
      timestamp: DateTime.to_unix(~U[2022-01-01 12:00:00Z], :millisecond),
      value: 1027
    },
    %{
      name: "http_requests_total",
      labels: %{"method" => "post", "code" => "400"},
      timestamp: DateTime.to_unix(~U[2022-01-01 12:00:00Z], :millisecond),
      value: 3
    },
    %{
      name: "http_requests_total",
      labels: %{"method" => "post", "code" => "200"},
      timestamp: DateTime.to_unix(~U[2022-01-01 18:00:00Z], :millisecond),
      value: 2143
    },
    %{
      name: "http_requests_total",
      labels: %{"method" => "post", "code" => "400"},
      timestamp: DateTime.to_unix(~U[2022-01-01 18:00:00Z], :millisecond),
      value: 12
    }
  ]

  defp insert_samples(samples) do
    samples =
      Enum.map(samples, fn %{labels: labels} = sample ->
        %{sample | labels: Jason.encode!(labels)}
      end)

    Repo.insert_all("naive_metrics", samples)
  end

  test "insert" do
    assert {4, _} = insert_samples(@samples)
  end

  describe "select" do
    setup do
      insert_samples(@samples)
      :ok
    end

    test "basic" do
      sql = """
      select timestamp, value
        from naive_metrics
        where name = 'http_requests_total' and
              json_extract(labels, '$.code') = '400'
      """

      assert Repo.query!(sql).rows == [
               [1_641_038_400_000, 3.0],
               [1_641_060_000_000, 12.0]
             ]
    end
  end
end
