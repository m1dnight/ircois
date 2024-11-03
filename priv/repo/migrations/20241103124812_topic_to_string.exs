defmodule Ircois.Repo.Migrations.TopicToString do
  use Ecto.Migration

  def change do
    alter table(:karma) do
      modify :subject, :text
    end
  end
end
