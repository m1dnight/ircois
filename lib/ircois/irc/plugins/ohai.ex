defmodule Bot.Ohai do
  require Logger

  @moduledoc """
  This is an example event handler that greets users when they join a channel
  """

  ##############################################################################
  # GenServer

  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    Logger.debug("Initializing plugin #{__MODULE__}")
    :random.seed(:os.timestamp())
    ExIRC.Client.add_handler(client, self())
    {:ok, client}
  end

  ##############################################################################
  # Event Handlers

  def handle_info({:joined, _channel}, client) do
    {:noreply, client}
  end

  def handle_info({:joined, channel, user}, client) do
    channel = String.trim(channel)
    ExIRC.Client.msg(client, :privmsg, channel, random_greeting(user.nick))
    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ##############################################################################
  # Helpers

  defp available_greetings do
    [
      &"ohai #{&1}",
      &"hey there, #{&1}",
      &"welcome to the party, #{&1}",
      &"hey, everyone, it's #{&1}!",
      &"whew... I'm glad you're back, #{&1}. I was lost without you.",
      &"salutations, #{&1}",
      &"greetings, #{&1}",
      &"#{&1}, where have you been all my uptime?",
      &"#{&1}: hiya",
      &"hey #{&1}",
      &"g'day #{&1}",
      &"#{&1}: I have been trained in the act of communication in which human beings intentionally make their presence known to each other, to show attention to, and to suggest a type of relationship or social status. My algorithm has determined the most appropriate salutation is: What up, yo?",
      &"#{&1}, this is your automated welcome message, lovingly crafted from locally-sourced, fair-trade electrons"
    ]
  end

  defp random_greeting(user) do
    greet =
      available_greetings()
      |> Enum.shuffle()
      |> hd

    greet.(user)
  end
end
