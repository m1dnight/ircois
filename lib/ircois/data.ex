defmodule Ircois.Data do
  alias Ircois.Message
  alias Ircois.Repo
  import Ecto.Query
  alias Ircois.PubSub

  ##############################################################################
  # Messages
  def store_message(attrs) do
    attrs = Map.put(attrs, :when, now_tz())

    struct(Message)
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> PubSub.notify_new_message()

  end

  def get_last_n(channel, n \\ 10) do
    query =
      from m in Message,
        order_by: [desc: m.when],
        where: m.channel == ^channel,
        limit: 10

    Repo.all(query)
    |> Enum.reverse()
  end

  ##############################################################################
  # Helpers
  defp now_tz() do
    tz = Application.get_env(:ircois, :timezone)
    DateTime.now!(tz)
  end
end
