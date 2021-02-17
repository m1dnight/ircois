defmodule IrcoisWeb.PageLive do
  use IrcoisWeb, :live_view
  require Logger
  alias Ircois.PubSub

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Socket mounted #{inspect socket, pretty: true} #{inspect self()}")
    default_channel = "#ircois"

    # Subscribe to updates from the channel.
    PubSub.subscribe()

    # Last n messages
    messages = Ircois.Data.get_last_n(default_channel, 10)

    socket = assign(socket, :messages, messages)
    socket = assign(socket, :channel, default_channel)
    {:ok, socket}
  end

  def handle_info({:new_message, message}, socket) do
    # Last n messages
    messages = Ircois.Data.get_last_n(socket.assigns.channel, 10)

    socket = assign(socket, :messages, messages)
    {:noreply, socket}
  end

  def handle_info({:new_karma, karma}, socket) do
  end

  defp show_time(datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.to_string()
  end
end
