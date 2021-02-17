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
    Logger.debug("Logging #{from.nick}: #{msg} in #{inspect(channel)}")
    from = from.nick
    msg = msg
    channel = channel
    Ircois.Data.store_message(%{:from => from, :content => msg, :channel => channel})

    for url <- filter_url(msg) do
      Ircois.Data.store_url(%{:from => from, :url => url})
    end

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ##############################################################################
  # Helpers

  def filter_url(string) do
    r = ~r"http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"

    r
    |> Regex.scan(string)
    |> Enum.flat_map(& &1)
  end
end
