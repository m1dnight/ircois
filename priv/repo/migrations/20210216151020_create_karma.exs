defmodule Ircois.Repo.Migrations.CreateKarma do
  use Ecto.Migration

  def change do
    create table(:karma) do
      add :subject, :string
      add :karma, :integer

      timestamps()
    end
  end
end
