defmodule Metri.Repo.Migrations.AddMetrics do
  use Ecto.Migration

  def change do
    create table(:naive_metrics, primary_key: false, options: "STRICT") do
      add :name, :text, null: false
      add :labels, :text, null: false
      add :timestamp, :integer, null: false
      add :value, :real, null: false
    end

    create index(:naive_metrics, [:name, :timestamp])

    create table(:samples, primary_key: false, options: "WITHOUT ROWID, STRICT") do
      add :series_id, :integer, primary_key: true, null: false
      add :timestamp, :integer, primary_key: true, null: false
      add :value, :real, null: false
    end

    create table(:metric_to_series, primary_key: false, options: "WITHOUT ROWID, STRICT") do
      add :metric_name_with_labels, :text, null: false, primary_key: true
      add :series_id, :integer, null: false
    end

    # can rowid = series_id?
    create table(:series_to_metric, primary_key: false, options: "WITHOUT ROWID, STRICT") do
      add :series_id, :integer, null: false, primary_key: true
      add :metric_name_with_labels, :text, null: false
    end

    create table(:label_to_series, primary_key: false, options: "WITHOUT ROWID, STRICT") do
      add :name, :text, null: false, primary_key: true
      add :value, :text, null: false, primary_key: true
      add :series_id, :integer, null: false, primary_key: true
    end
  end
end
