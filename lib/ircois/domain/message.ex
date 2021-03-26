defmodule Ircois.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :from, :string
    field :channel, :string
    field :when, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:from, :content, :when, :channel])
    |> validate_required([:from, :content, :when, :channel])
  end
end
