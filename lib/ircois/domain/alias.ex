defmodule Ircois.Alias do
  use Ecto.Schema
  import Ecto.Changeset

  schema "aliases" do
    field :name, :string
    field :alias, :string
    field :when, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(alias, attrs) do
    alias
    |> cast(attrs, [:name, :alias, :when])
    |> validate_required([:name, :alias, :when])
  end
end
