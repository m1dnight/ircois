defmodule Ircois.Repo.Migrations.Aliases do
  use Ecto.Migration

  def change do
    create table(:aliases) do
      add :name, :string
      add :alias, :string
      add :when, :utc_datetime

      timestamps()
    end

  end
end
