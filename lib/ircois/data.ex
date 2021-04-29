defmodule Ircois.Data do
  alias Ircois.{Message, Karma, URL, Balance, Fact}
  alias Ircois.Repo
  import Ecto.Query
  alias Ircois.PubSub

  ##############################################################################
  # Messages
  def store_message(attrs = %{:from => _, :content => _, :channel => _, :when => _}) do
    struct(Message)
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> PubSub.notify_new_message()
  end

  def store_message(%{:from => random_nick, :content => message, :channel => channel}) do
    attrs = %{:from => random_nick, :content => message, :channel => channel, :when => now_tz()}
    store_message(attrs)
  end

  def grep(pattern, channel) do
    pattern = Regex.replace(~r/([\%_])/, pattern, "\\\\\\g{0}")

    query =
      from m in Message,
        where: m.channel == ^channel and like(m.content, ^"%#{pattern}%"),
        order_by: [desc: m.when],
        limit: 1000

    Repo.all(query)
  end

  def grep(pattern, channel, nickname) do
    pattern = Regex.replace(~r/([\%_])/, pattern, "\\\\\\g{0}")

    query =
      from m in Message,
        where: m.channel == ^channel and like(m.content, ^"%#{pattern}%") and fragment("lower(?)", m.from) == fragment("lower(?)", ^nickname),
        order_by: [desc: m.when],
        limit: 1000

    Repo.all(query)
  end

  def first_seen(channel, nickname) do
    query =
      from m in Message,
        order_by: [asc: m.when],
        where: m.channel == ^channel and fragment("lower(?)", m.from) == fragment("lower(?)", ^nickname),
        limit: 1

    case Repo.one(query) do
      nil ->
        nil

      m ->
        tz = Application.get_env(:ircois, :timezone)
        %{m | when: DateTime.shift_zone!(m.when, tz)}
    end
  end

  def last_seen(channel, nickname) do
    query =
      from m in Message,
        order_by: [desc: m.when],
        where: m.channel == ^channel and fragment("lower(?)", m.from) == fragment("lower(?)", ^nickname),
        limit: 1

    case Repo.one(query) do
      nil ->
        nil

      m ->
        tz = Application.get_env(:ircois, :timezone)
        %{m | when: DateTime.shift_zone!(m.when, tz)}
    end
  end

  def get_last_n(channel, n \\ 10) do
    query =
      from m in Message,
        order_by: [desc: m.when],
        where: m.channel == ^channel,
        limit: ^n

    tz = Application.get_env(:ircois, :timezone)

    Repo.all(query)
    |> Enum.map(fn m ->
      %{m | when: DateTime.shift_zone!(m.when, tz)}
    end)
  end

  def message_count_per_day(channel) do
    subquery =
      from m in Message,
        select: %{
          when_tz: fragment("(? AT TIME ZONE 'UTC')", m.when),
          day_tz: fragment("date_trunc('day', (? AT TIME ZONE 'UTC'))", m.when)
        },
        where:
          fragment(
            "date_trunc('day', (? AT TIME ZONE 'UTC')) > (NOW() - interval ?)",
            m.when,
            "31 days"
          ) and m.channel == ^channel

    query =
      from m in subquery(subquery),
        select: %{
          total: fragment("count(*)"),
          day: m.day_tz
        },
        group_by: fragment("day_tz")

    Repo.all(query)
    |> Enum.map(fn %{total: t, day: d} ->
      tz_day = DateTime.shift_zone!(d, Application.get_env(:ircois, :timezone))
      %{total: t, day: tz_day, utc: d}
    end)
    |> Enum.sort_by(fn d -> d.day end)
  end

  def message_count_per_hour(channel) do
    subquery =
      from m in Message,
        select: %{
          when_tz: fragment("(? AT TIME ZONE 'UTC')", m.when),
          hour_tz: fragment("date_trunc('hour', (? AT TIME ZONE 'UTC'))", m.when)
        },
        where:
          fragment(
            "? > (now() - interval '48 hours')",
            m.when
          ) and m.channel == ^channel

    query =
      from m in subquery(subquery),
        select: %{
          total: fragment("count(*)"),
          hour: m.hour_tz
        },
        group_by: fragment("hour_tz")

    Repo.all(query)
    |> Enum.map(fn %{total: t, hour: h} ->
      tz_hour = DateTime.shift_zone!(h, Application.get_env(:ircois, :timezone))
      %{total: t, hour: tz_hour, utc: h}
    end)
    |> Enum.sort_by(fn d -> d.hour end)
  end

  def most_active(channel) do
    q =
      from m in Message,
        select: [fragment("lower(?)", m.from), count()],
        where: m.channel == ^channel,
        group_by: fragment("lower(?)", m.from),
        order_by: [desc: count()],
        limit: 10

    Repo.all(q)
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

  #############################################################################
  # Remembers

  def remember(name, description) do
    f = Repo.one(from f in Fact, where: fragment("lower(?)", f.name) == fragment("lower(?)", ^name))

    if f != nil do
      Ecto.Changeset.change(f, description: description)
      |> Repo.update()
      |> PubSub.notify_fact_update()
    else
      struct(Fact)
      |> Fact.changeset(%{:name => name, :description => description})
      |> Repo.insert()
      |> PubSub.notify_fact_update()
    end
  end

  def known?(name) do
    query =
      from f in Fact,
        where: fragment("lower(?)", f.name) == fragment("lower(?)", ^name)

    case Repo.one(query) do
      nil ->
        nil

      f ->
        f.description
    end
  end

  ##############################################################################
  # Karma

  def get_karma(subject) do
    query =
      from m in Karma,
        where: fragment("lower(?)", m.subject) == fragment("lower(?)", ^subject)
    case Repo.one(query) do
      nil ->
        0

      n ->
        n.karma
    end
  end

  def add_karma(subject, delta \\ 1) do
    s = Repo.one(from m in Karma, where: fragment("lower(?)", m.subject) == fragment("lower(?)", ^subject))

    if s != nil do
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

  def karma_top(n \\ nil) do
    query =
      if n do
        from m in Karma,
          order_by: [desc: m.karma],
          limit: ^n
      else
        from m in Karma,
          order_by: [desc: m.karma]
      end

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
