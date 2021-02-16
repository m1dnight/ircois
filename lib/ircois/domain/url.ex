defmodule Ircois.URL do
  use Ecto.Schema
  import Ecto.Changeset

  schema "urls" do
    field :url, :string
    field :from, :string
    field :when, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(url, attrs) do
    url
    |> cast(attrs, [:url, :from, :when])
    |> validate_required([:url, :from, :when])
  end
end
