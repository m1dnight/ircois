defmodule Ircois.Balance do
  use Ecto.Schema
  import Ecto.Changeset

  schema "balance" do
    field :left, :integer
    field :right, :integer

    timestamps()
  end

  @doc false
  def changeset(balance, attrs) do
    balance
    |> cast(attrs, [:left, :right])
    |> validate_required([:left, :right])
  end
end
