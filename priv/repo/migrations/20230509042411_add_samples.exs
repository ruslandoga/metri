defmodule Metri.Repo.Migrations.AddSamples do
  use Ecto.Migration

  def change do
    create table(:samples, primary_key: false, options: "STRICT") do
      add :name, :text, null: false
      add :labels, :text, null: false
      add :timestamp, :integer, null: false
      add :value, :real, null: false
    end

    create index(:samples, [:name, :timestamp])
  end
end
