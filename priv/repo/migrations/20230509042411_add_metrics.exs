defmodule Metri.Repo.Migrations.AddMetrics do
  use Ecto.Migration

  @opts [primary_key: false, options: "WITHOUT ROWID, STRICT"]

  def change do
    create table(:samples, @opts) do
      add :series_id, :integer, primary_key: true, null: false
      add :timestamp, :integer, primary_key: true, null: false
      add :value, :real, null: false
    end

    # create table(:metric_to_series, @opts) do
    #   add :metric_name_with_labels, :text, null: false, primary_key: true
    #   add :series_id, :integer, null: false
    # end

    # create table(:series_to_metric, @opts) do
    #   add :series_id, :integer, null: false, primary_key: true
    #   add :metric_name_with_labels, :text, null: false
    # end

    create table(:label_to_series, @opts) do
      # TODO vs label_name_value
      add :name, :text, null: false, primary_key: true
      add :value, :text, null: false, primary_key: true
      add :series_id, :integer, null: false, primary_key: true
    end

    # execute """
    # CREATE VIEW metrics AS
    #   SELECT
    # """,
    # """
    # """
  end
end
