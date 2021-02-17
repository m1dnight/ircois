defmodule Ircois.Karma do
  use Ecto.Schema
  import Ecto.Changeset

  schema "karma" do
    field :subject, :string
    field :karma, :integer

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:karma, :subject])
    |> validate_required([:karma, :subject])
  end
end
