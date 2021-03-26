defmodule LoginHandler do
  require Logger

  @moduledoc """
  This is an example event handler that listens for login events and then
  joins the appropriate channels. We actually need this because we can't
  join channels until we've waited for login to complete. We could just
  attempt to sleep until login is complete, but that's just hacky. This
  as an event handler is a far more elegant solution.
  """
  def start_link(client, config) do
    GenServer.start_link(__MODULE__, [client, config])
  end

  def init([client, config]) do
    ExIRC.Client.add_handler(client, self())
    {:ok, {client, config}}
  end

  def handle_info(:logged_in, state = {client, config}) do
    Logger.debug("Logged in to server")

    config
    |> Map.get(:channels)
    |> Enum.map(&ExIRC.Client.join(client, &1))

    {:noreply, state}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
