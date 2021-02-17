defmodule Bot.Karma do
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
    init_state()
    ExIRC.Client.add_handler(client, self())
    {:ok, client}
  end

  ##############################################################################
  # State

  def init_state() do
    if get() == nil do
      put(%{})
    end
  end

  @spec get_karma(any) :: any
  def get_karma(nickname) do
    karmas = get()

    case karmas do
      %{^nickname => karma} ->
        karma

      _ ->
        0
    end
  end

  def all_karma() do
    get()
  end

  def update_karma(nickname, delta \\ 1) do
    Logger.debug("Updating karma for #{nickname} with #{delta}")

    apply!(fn state ->
      Map.update(state, nickname, delta, &(&1 + delta))
    end)
  end

  ##############################################################################
  # Event Handlers

  # If this is a command, handle it.
  def handle_info({:received, msg = <<"karma"::utf8, _::bitstring>>, _from, channel}, client) do
    regex = ~r/\s*karma\s+(?<subject>[^\s\?]+)\??/

    if Regex.match?(regex, msg) do
      %{"subject" => s} = Regex.named_captures(regex, msg)
      s = String.trim(s)
      karma = get_karma(s)
      ExIRC.Client.msg(client, :privmsg, channel, "#{s} has #{karma} karmapoints.")
    end

    {:noreply, client}
  end

  # Keep track of karmas in sentences.
  def handle_info({:received, message, _from, _channel}, client) do
    regex = ~r/([^\s]+)(\+\+|--)/

    Regex.scan(regex, message)
    |> Enum.map(fn [_, subject, operation] ->
      delta = if operation == "++", do: 1, else: -1
      update_karma(subject, delta)
    end)

    {:noreply, client}
  end

  def handle_info({:received, "list karmas", from = %ExIRC.SenderInfo{}}, client) do
    top = 100

    Task.async(fn ->
      all_karma()
      |> Enum.into([])
      |> Enum.sort_by(&elem(&1, 1), :desc)
      |> Enum.take(top)
      |> Enum.zip(1..top)
      |> Enum.map(fn {{subject, karma}, rank} ->
        ExIRC.Client.msg(client, :privmsg, from.nick, "#{rank}> #{subject}: #{karma}")
        Process.sleep(1000)
      end)
    end)

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
