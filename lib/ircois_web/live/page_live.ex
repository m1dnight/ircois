defmodule IrcoisWeb.PageLive do
  use IrcoisWeb, :live_view
  require Logger
  alias Ircois.PubSub

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Socket mounted #{inspect socket, pretty: true} #{inspect self()}")


    # Subscribe to updates from the channel.
    PubSub.subscribe()

    # Last n messages
    messages = Ircois.Data.get_last_n("#ircois", 10)

    socket = assign(socket, :messages, messages)
    {:ok, socket}
  end

  def handle_info(%Ircois.Message{}, socket) do
    # Last n messages
    messages = Ircois.Data.get_last_n("#ircois", 10)

    socket = assign(socket, :messages, messages)
    {:noreply, socket}
  end

  defp show_time(datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.to_string()
  end
end
