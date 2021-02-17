defmodule Ircois.Repo.Migrations.CreateBalance do
  use Ecto.Migration

  def change do
    create table(:balance) do
      add :left, :integer
      add :right, :integer

      timestamps()
    end

  end
end
