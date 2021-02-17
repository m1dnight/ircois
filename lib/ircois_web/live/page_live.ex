defmodule IrcoisWeb.PageLive do
  use IrcoisWeb, :live_view
  require Logger
  alias Phoenix.PubSub

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Socket mounted")

    # Subscribe to updates from the channel.
    PubSub.subscribe(Ircois.PubSub, "messages")

    # Last n messages
    messages = Ircois.Data.get_last_n("#ircois", 10)

    socket = assign(socket, :messages, messages)
    {:ok, socket}
  end

  @impl true
  def handle_event(event, _params, socket) do
    Logger.error("HANDLE EVENT FOR #{inspect(event)}")
    {:noreply, socket}
  end

  @impl true
  def handle_info(message, socket) do
    Logger.error("HANDLE INFO FOR #{inspect(message)}")
    {:noreply, socket}
  end

  defp show_time(datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.to_string()
  end
end
