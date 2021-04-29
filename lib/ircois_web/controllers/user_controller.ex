defmodule IrcoisWeb.UserController do
  use IrcoisWeb, :controller

  def user(conn, %{"user" => username}) do
    cfg = Ircois.Config.read_config()
    default_channel = hd(cfg.channels)

    data = %{nickname: username}
    # Activity per hour.
    buckets = Ircois.Statistics.active_hours(username, default_channel)
    most_active_start = buckets |> Map.to_list() |> Enum.sort_by(&elem(&1, 1), :desc) |> hd |> elem(0)
    most_active = {most_active_start, Time.add(most_active_start, 3600)}
    data = Map.put(data, :activity_buckets, buckets)
    data = Map.put(data, :most_active, most_active)

    # Total messages
    total = Ircois.Statistics.total_messages(username, default_channel)
    data = Map.put(data, :total, total)

    # Averag per day
    day_avg = Ircois.Statistics.avg_per_day(username, default_channel)
    data = Map.put(data, :avg_per_day, day_avg)

    # Karma
    karma = Ircois.Data.get_karma(username)
    data = Map.put(data, :karma, karma)

    # Last seen
    last_seen = Ircois.Data.last_seen(default_channel, username)

    data =
      case last_seen do
        nil ->
          Map.put(data, :last_seen, nil)

        _ ->
          Map.put(data, :last_seen, last_seen.when)
      end

    # First seen
    first_seen = Ircois.Data.first_seen(default_channel, username)

    data =
      case first_seen do
        nil ->
          Map.put(data, :first_seen, nil)

        _ ->
          Map.put(data, :first_seen, first_seen.when)
      end

    render(conn, "index.html", data: data)
  end
end
