defmodule Ircois.Fact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "facts" do
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:name, :description])
    |> validate_required([:name, :description])
  end
end
