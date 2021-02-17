defmodule Bot.Logger do
  require Logger

  @moduledoc """
  This plugin keeps track of people and what they say last.

  It listens to the commands seen <nickname>.
  """

  ##############################################################################
  # GenServer

  def start_link(client) do
    GenServer.start_link(__MODULE__, [client], name: __MODULE__)
  end

  def init([client]) do
    Logger.debug("Initializing plugin #{__MODULE__}")
    ExIRC.Client.add_handler(client, self())
    {:ok, client}
  end

  ##############################################################################
  # Event Handlers
  def handle_info({:received, msg, from, channel}, client) do
    Logger.debug "Logging #{from.nick}: #{msg} in #{inspect channel}"
    from = from.nick
    msg = msg
    channel = channel
    Ircois.Data.store_message(%{:from => from, :content => msg, :channel => channel})
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
