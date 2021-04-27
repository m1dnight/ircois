defmodule Ircois.Repo.Migrations.Facts do
  use Ecto.Migration

  def change do
    create table(:facts) do
      add :name, :string
      add :description, :string

      timestamps()
    end
  end
end
