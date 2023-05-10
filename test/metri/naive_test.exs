defmodule Metri.NaiveTest do
  use Metri.DataCase, async: true

  test "insert" do
    samples = [
      %{name: "http_requests_total", labels: %{}, timestamp: 0, value: 0},
      %{name: "http_requests_total", labels: %{}, timestamp: 0, value: 0}
    ]

    assert {2, _} = Repo.insert_all("naive_metrics", samples)
  end

  describe "select" do
    setup do
      samples = [
        %{name: "http_requests_total", labels: %{}, timestamp: 0, value: 0},
        %{name: "http_requests_total", labels: %{}, timestamp: 0, value: 0}
      ]

      Repo.insert_all("naive_metrics", samples)

      :ok
    end

    test "select for chart" do
    end

    test "select for table"
  end
end
