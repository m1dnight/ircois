defmodule IrcoisWeb.SearchLive do
  use IrcoisWeb, :live_view
  require Logger
  alias Ircois.PubSub

  def mount(_params, _session, socket) do
    Logger.debug("Socket mounted #{inspect(socket, pretty: true)} #{inspect(self())}")
    PubSub.subscribe()
    socket = assign(socket, :messages, [])
    {:ok, socket}
  end

  def handle_event("search", %{"query" => query}, socket) do
    cfg = Ircois.Config.read_config()
    channel = hd(cfg.channels)
    # Sanitize input.

    # Ignore empty queries.
    case String.trim(query) do
      "" ->
        {:noreply, socket}

      _ ->
        from = Regex.named_captures(~r/from:(?<from>(\w+))?/i, query)

        matches =
          if from == nil or from["from"] == "" do
            Ircois.Data.grep(query, channel)
          else
            query = Regex.replace(~r/from:(?<from>(\w+))?/i, query, "") |> String.trim()
            Ircois.Data.grep(query, channel, from["from"])
          end

        color_map = nick_color_map(matches)

        socket = assign(socket, :messages, matches)
        socket = assign(socket, :color_map, color_map)

        {:noreply, socket}
    end
  end

  def handle_info(_m, socket) do
    {:noreply, socket}
  end

  defp show_time(dt) do
    Timex.format!(dt, "%d/%m/%Y %H:%M", :strftime)
  end

  def labels_day(dt) do
    day = "#{dt.day}"
    month = "#{dt.month}" |> String.pad_leading(2, "0")
    "#{day}/#{month}"
  end

  def labels_hour(dt) do
    day = "#{dt.day}"
    month = "#{dt.month}" |> String.pad_leading(2, "0")
    hour = "#{dt.hour}" |> String.pad_leading(2, "0")
    minute = "#{dt.minute}" |> String.pad_leading(2, "0")
    "#{day}/#{month} #{hour}:#{minute}"
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
