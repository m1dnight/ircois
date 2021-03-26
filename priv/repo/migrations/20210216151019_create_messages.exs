defmodule Ircois.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :from, :string
      add :content, :string
      add :when, :utc_datetime
      add :channel, :string

      timestamps()
    end
  end
end
