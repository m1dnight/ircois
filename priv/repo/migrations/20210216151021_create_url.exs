defmodule Ircois.Repo.Migrations.CreateURL do
  use Ecto.Migration

  def change do
    create table(:urls) do
      add :url, :string
      add :from, :string
      add :when, :utc_datetime

      timestamps()
    end
  end
end
