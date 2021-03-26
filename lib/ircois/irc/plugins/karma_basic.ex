defmodule Bot.KarmaBasic do
  require Logger

  @moduledoc """
  This plugin keeps track of karma of things.

  It listens to the commands `<subject>++`.
  """

  ##############################################################################
  # GenServer

  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    Logger.debug("Initializing plugin #{__MODULE__}")
    ExIRC.Client.add_handler(client, self())
    {:ok, client}
  end

  ##############################################################################
  # Event Handlers

  # If this is a command, handle it.
  def handle_info({:received, msg = <<"karma"::utf8, _::bitstring>>, _from, channel}, client) do
    regex = ~r/\s*karma\s+(?<subject>[^\s\?]+)\??/

    if Regex.match?(regex, msg) do
      %{"subject" => s} = Regex.named_captures(regex, msg)
      s = String.trim(s)
      karma = Ircois.Data.get_karma(s)
      ExIRC.Client.msg(client, :privmsg, channel, "#{s} has #{karma} karmapoints.")
    end

    {:noreply, client}
  end

  # Keep track of karmas in sentences.
  def handle_info({:received, message, _from, _channel}, client) do
    regex = ~r/!(.+)(\+\+|--)/

    Regex.scan(regex, message)
    |> Enum.map(fn [_, subject, operation] ->
      delta = if operation == "++", do: 1, else: -1
      Ircois.Data.add_karma(subject, delta)
    end)

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
