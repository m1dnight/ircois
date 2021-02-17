defmodule Bot.UwMoeder do
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
    :random.seed(:os.timestamp())
    {:ok, client}
  end

  ##############################################################################
  # Event Handlers

  # Keep track of karmas in sentences.
  def handle_info({:received, msg, _from, channel}, client) do
    regex = ~r/.*\sis\s(.+\s)?een(?<wat>(\s*[a-zA-Z]+\s*)+)/

    if Regex.match?(regex, msg) and :rand.uniform() > 0.95 do
      %{"wat" => w} = Regex.named_captures(regex, msg)
      w = String.trim(w)
      ExIRC.Client.msg(client, :privmsg, channel, "Uw moeder is een #{w}.")
    end

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
