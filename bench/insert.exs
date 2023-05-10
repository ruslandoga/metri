alias Exqlite.Sqlite3

series = [
  %{
    id: 1,
    metric: "http_requests_total",
    labels: %{"code" => "200", "method" => "post"}
  },
  %{
    id: 2,
    metric: "http_requests_total",
    labels: %{"code" => "400", "method" => "post"}
  }
]

start_at = DateTime.to_unix(~U[2023-01-01 00:00:00Z], :millisecond)

naive_metrics =
  for day <- 1..30,
      hour <- 0..23,
      minute <- [0, 10, 20, 30, 40, 50],
      %{metric: metric, labels: labels} <- series do
    [
      metric: metric,
      labels: Jason.encode!(labels),
      value: :rand.uniform(1000),
      timestamp: start_at + ((day * 24 + hour) * 60 + minute) * 60000
    ]
  end

series_metrics =
  for day <- 1..30,
      hour <- 0..23,
      minute <- [0, 10, 20, 30, 40, 50],
      %{id: series_id} <- series do
    [
      series_id: series_id,
      value: :rand.uniform(1000),
      timestamp: start_at + ((day * 24 + hour) * 60 + minute) * 60000
    ]
  end

flat_naive_metrics =
  Enum.map(naive_metrics, fn kv ->
    {_k, v} = Enum.unzip(kv)
    v
  end)

flat_series_metrics =
  Enum.map(series_metrics, fn kv ->
    {_k, v} = Enum.unzip(kv)
    v
  end)

defmodule NaiveRepo do
  use Ecto.Repo, otp_app: :bench, adapter: Ecto.Adapters.SQLite3
end

defmodule SeriesRepo do
  use Ecto.Repo, otp_app: :bench, adapter: Ecto.Adapters.SQLite3
end

for file <- Path.wildcard("naive.*"), do: File.rm!(file)
for file <- Path.wildcard("naive1.*"), do: File.rm!(file)
for file <- Path.wildcard("naive2.*"), do: File.rm!(file)
for file <- Path.wildcard("series.*"), do: File.rm!(file)
for file <- Path.wildcard("series1.*"), do: File.rm!(file)

File.touch!("naive.csv")
naive_csv = File.open!("naive.csv", [:append, {:delayed_write, 512_000, 10_000}])
File.touch!("series.csv")
series_csv = File.open!("series.csv", [:append, {:delayed_write, 512_000, 10_000}])

NaiveRepo.start_link(
  database: "naive1.db",
  pool_size: 1,
  wal_auto_check_point: 0,
  cache_size: -2000
)

NaiveRepo.query!(
  "create table samples(metric text, labels text, value real, timestamp integer) strict"
)

{:ok, naive2} = Sqlite3.open("naive2.db")
:ok = Sqlite3.execute(naive2, "pragma cache_size = -2000")
:ok = Sqlite3.execute(naive2, "pragma wal_auto_check_point = 0")

:ok =
  Sqlite3.execute(
    naive2,
    "create table samples(metric text, labels text, value real, timestamp integer) strict"
  )

{:ok, naive2_stmt} =
  Sqlite3.prepare(
    naive2,
    "insert into samples(metric, labels, value, timestamp) values(?, ?, ?, ?)"
  )

SeriesRepo.start_link(
  database: "series1.db",
  pool_size: 1,
  wal_auto_check_point: 0,
  cache_size: -2000
)

SeriesRepo.query!("create table samples(series_id integer, value real, timestamp integer) strict")

Benchee.run(
  %{
    "control" => fn ->
      naive_metrics
      |> Enum.chunk_every(20)
      |> Enum.each(fn _chunk -> :ok end)
    end,
    "naive insert_all (chunk=20)" => fn ->
      naive_metrics
      |> Enum.chunk_every(20)
      |> Enum.each(fn chunk -> NaiveRepo.insert_all("samples", chunk) end)
    end,
    "naive prepared stmt" => fn ->
      flat_naive_metrics
      |> Enum.chunk_every(20)
      |> Enum.each(fn chunk ->
        :ok = Sqlite3.execute(naive2, "begin")

        Enum.each(chunk, fn row ->
          :ok = Sqlite3.bind(naive2, naive2_stmt, row)
          :done = Sqlite3.step(naive2, naive2_stmt)
        end)

        :ok = Sqlite3.execute(naive2, "commit")
      end)
    end,
    "series_id insert_all (chunk=20)" => fn ->
      series_metrics
      |> Enum.chunk_every(20)
      |> Enum.each(fn chunk -> SeriesRepo.insert_all("samples", chunk) end)
    end,
    # "series_id prepare stmt" => fn -> :ok end,
    "csv naive" => fn ->
      flat_naive_metrics
      |> Enum.chunk_every(20)
      |> Enum.each(fn chunk -> :file.write(naive_csv, NimbleCSV.RFC4180.dump_to_iodata(chunk)) end)
    end,
    "csv series_id" => fn ->
      flat_series_metrics
      |> Enum.chunk_every(20)
      |> Enum.each(fn chunk ->
        :file.write(series_csv, NimbleLZ4.compress(NimbleCSV.RFC4180.dump_to_iodata(chunk)))
      end)
    end
    # "educkdb appender naive" => fn -> :ok end,
    # "educkdb appender series_id" => fn -> :ok end,
    # "duckdbex appender naive" => fn -> :ok end,
    # "duckdbex appender series_id" => fn -> :ok end,
    # "exduckdb appender naive" => fn -> :ok end,
    # "exduckdb appender series_id" => fn -> :ok end
  },
  memory_time: 2
)

IO.puts("")
IO.inspect(length(naive_metrics), label: "metrics count")

NaiveRepo.query!("pragma wal_checkpoint(truncate)")
IO.inspect(NaiveRepo.aggregate("samples", :count), label: "naive1 samples count")
IO.inspect(File.stat!("naive1.db").size / 1_000_000, label: "naive1 db size (MB)")

SeriesRepo.query!("pragma wal_checkpoint(truncate)")
IO.inspect(SeriesRepo.aggregate("samples", :count), label: "series1 samples count")
IO.inspect(File.stat!("series1.db").size / 1_000_000, label: "series1 db size (MB)")
