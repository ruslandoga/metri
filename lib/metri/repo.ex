defmodule Metri.Repo do
  use Ecto.Repo, otp_app: :metri, adapter: Ecto.Adapters.SQLite3
end
