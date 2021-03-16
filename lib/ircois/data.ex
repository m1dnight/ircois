defmodule Ircois.Data do
  alias Ircois.{Message, Karma, URL, Balance}
  alias Ircois.Repo
  import Ecto.Query
  alias Ircois.PubSub

  ##############################################################################
  # Messages
  def store_message(attrs) do
    attrs = Map.put(attrs, :when, now_tz())

    IO.inspect attrs
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
        limit: ^n

    Repo.all(query)
    |> Enum.reverse()
  end



  ##############################################################################
  # URLs
  def store_url(attrs) do
    attrs = Map.put(attrs, :when, now_tz())

    struct(URL)
    |> URL.changeset(attrs)
    |> Repo.insert()
    |> PubSub.notify_new_url()
  end

  def last_n_urls(n \\ 10) do
    query =
      from m in URL,
        order_by: [desc: m.when],
        limit: ^n

    Repo.all(query)
    |> Enum.reverse()
  end

  ##############################################################################
  # Karma

  def get_karma(subject) do
    query =
      from m in Karma,
        where: m.subject == ^subject

    case Repo.one(query) do
      nil ->
        0

      n ->
        n.karma
    end
  end

  def add_karma(subject, delta \\ 1) do
    s = Repo.one(from m in Karma, where: m.subject == ^subject)

    if s != nil do
      IO.puts("Updating existing karma #{inspect(subject)}")

      Ecto.Changeset.change(s, karma: s.karma + delta)
      |> Repo.update()
      |> PubSub.notify_karma_update()
    else
      struct(Karma)
      |> Karma.changeset(%{:karma => delta, :subject => subject})
      |> Repo.insert()
      |> PubSub.notify_karma_update()
    end
  end

  def karma_top(n \\ 10) do
    query =
      from m in Karma,
        order_by: [desc: m.karma],
        limit: ^n

    Repo.all(query)
  end

  def karma_bottom(n \\ 10) do
    query =
      from m in Karma,
        order_by: [asc: m.karma],
        limit: ^n

    Repo.all(query)
  end

  ##############################################################################
  # Helpers
  defp now_tz() do
    tz = Application.get_env(:ircois, :timezone)
    DateTime.now!(tz)
  end
end
