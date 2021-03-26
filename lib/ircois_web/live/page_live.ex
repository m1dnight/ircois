defmodule IrcoisWeb.PageLive do
  use IrcoisWeb, :live_view
  require Logger
  alias Ircois.PubSub

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Socket mounted #{inspect(socket, pretty: true)} #{inspect(self())}")
    default_channel = "#ircois"

    # Subscribe to updates from the channel.
    PubSub.subscribe()

    # Last n messages
    messages = Ircois.Data.get_last_n(default_channel, 10) |> color_nicknames()
    socket = assign(socket, :messages, messages)

    # Karma top 10
    karma_top_10 = Ircois.Data.karma_top(3)
    socket = assign(socket, :karma_top_10, karma_top_10)

    # Karma bottom 10
    karma_bottom_10 = Ircois.Data.karma_bottom(3)
    socket = assign(socket, :karma_bottom_10, karma_bottom_10)

    # URLS
    urls = Ircois.Data.last_n_urls(3)
    socket = assign(socket, :urls, urls)

    socket = assign(socket, :channel, default_channel)
    {:ok, socket}
  end

  @impl true
  def handle_info({:new_message, _message}, socket) do
    Logger.debug("Sending new message to front-end")
    # Last n messages
    messages = Ircois.Data.get_last_n(socket.assigns.channel, 10) |> color_nicknames()

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

  defp color_nicknames(messages) do
    :random.seed(:os.timestamp())

    {_, messages} =
      messages
      |> Enum.reduce({%{}, []}, fn message, {colors, messages} ->
        colors =
          Map.put_new(colors, message.from, :rand.uniform(16_777_215) |> Integer.to_string(16))

        color = Map.get(colors, message.from)
        new_message = Map.put(message, :color, color)
        {colors, [new_message | messages]}
      end)

    messages
  end
end
