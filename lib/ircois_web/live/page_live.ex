defmodule IrcoisWeb.PageLive do
  use IrcoisWeb, :live_view
  require Logger
  alias Ircois.PubSub

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Socket mounted #{inspect(socket, pretty: true)} #{inspect(self())}")
    cfg = Ircois.Config.read_config("config.json")

    default_channel = hd(cfg.channels)

    # Subscribe to updates from the channel.
    PubSub.subscribe()

    # Last n messages
    messages = Ircois.Data.get_last_n(default_channel, 10)
    color_map = nick_color_map(messages)
    socket = assign(socket, :messages, messages)
    socket = assign(socket, :color_map, color_map)

    # Karma top 10
    karma_top_10 = Ircois.Data.karma_top(10)
    socket = assign(socket, :karma_top_10, karma_top_10)

    # Karma bottom 10
    karma_bottom_10 = Ircois.Data.karma_bottom(10)
    socket = assign(socket, :karma_bottom_10, karma_bottom_10)

    # URLS
    urls = Ircois.Data.last_n_urls(10)
    socket = assign(socket, :urls, urls)

    # Activity
    day_totals = Ircois.Data.message_count_per_day(default_channel)
    hour_totals = Ircois.Data.message_count_per_hour(default_channel)
    socket = assign(socket, :day_totals, day_totals)
    socket = assign(socket, :hour_totals, hour_totals)

    socket = assign(socket, :channel, default_channel)
    {:ok, socket}
  end

  @impl true
  def handle_info({:new_message, message}, socket) do
    # Generate color map if the current user is not in there yet.
    color_map = socket.assigns.color_map
                |> Map.put_new(message.from, random_color())
    socket = assign(socket, :color_map, color_map)

    # Only keep the last n messages.
    messages = socket.assigns.messages ++ [message] |> Enum.take(-10)
    socket = assign(socket, :messages, messages)

    {:noreply, socket}
  end

  def handle_info({:new_karma, _karma}, socket) do
    # Top 10 Karma
    karma_top_10 = Ircois.Data.karma_top(10)
    socket = assign(socket, :karma_top_10, karma_top_10)

    karma_bottom_10 = Ircois.Data.karma_bottom(10)
    socket = assign(socket, :karma_bottom_10, karma_bottom_10)
    {:noreply, socket}
  end

  def handle_info({:new_url, _karma}, socket) do
    # URLS
    urls = Ircois.Data.last_n_urls(12)
    socket = assign(socket, :urls, urls)
    {:noreply, socket}
  end

  defp show_time(datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.to_string()
  end

  def hour_totals_labels(hourtotals) do
    hourtotals
    |> Enum.map(fn %{hour: hour} ->
      hour
    end)
    |> Enum.map(&labels_hour/1)
    |> Jason.encode!()
  end

  def hour_totals_values(hourtotals) do
    hourtotals
    |> Enum.map(fn %{total: t} ->
      t
    end)
    |> Jason.encode!()
  end

  def day_totals_labels(daytotals) do
    daytotals
    |> Enum.map(fn %{day: day} ->
      day
    end)
    |> Enum.map(&labels_day/1)
    |> Jason.encode!()
  end

  def day_totals_values(daytotals) do
    daytotals
    |> Enum.map(fn %{total: t} ->
      t
    end)
    |> Jason.encode!()
  end

  def labels_day(dt) do
    day = "#{dt.day}"
    month = "#{dt.month}" |> String.pad_leading(2, "0")
    "#{day}/#{month}"
  end

  def labels_hour(dt) do
    hour = "#{dt.hour}" |> String.pad_leading(2, "0")
    minute = "#{dt.minute}" |> String.pad_leading(2, "0")
    "#{hour}:#{minute}"
  end

  defp nick_color_map(messages) do
    messages
    |> Enum.map(fn m -> m.from end)
    |> Enum.uniq()
    |> Enum.map(fn n ->
      {n, random_color()}
    end)
    |> Enum.into(%{})
  end

  defp random_color() do
    :rand.uniform(16_777_215) |> Integer.to_string(16)
  end
end
