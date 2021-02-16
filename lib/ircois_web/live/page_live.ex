defmodule IrcoisWeb.PageLive do
  use IrcoisWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    Logger.debug("Socket mounted")
    socket = assign(socket, :text, "Hello, LiveView!")
    {:ok, socket}
  end
end
