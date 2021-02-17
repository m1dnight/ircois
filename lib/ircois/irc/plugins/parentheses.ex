defmodule Bot.Parentheses do
  require Logger
  require Brain.Memory
  import Brain.Memory

  @moduledoc """
  This module parses the parentheses used in the chat and keeps track of whether all opened ones are closed.
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
      put(%{"(" => 0, ")" => 0})
    end
  end

  def balanced?() do
    case get() do
      %{"(" => o, ")" => c} when c == o -> true
      _ -> false
    end
  end

  def update("(") do
    get()
    |> Map.update!("(", &(&1 + 1))
    |> put()
  end

  def update(")") do
    get()
    |> Map.update!(")", &(&1 + 1))
    |> put()
  end

  ##############################################################################
  # Event Handlers

  def handle_info({:received, "balanced?", _from, channel}, client) do
    if balanced?() do
      ExIRC.Client.msg(client, :privmsg, channel, "Yes.")
    else
      %{"(" => o, ")" => c} = get()

      message =
        if o > c do
          "missing #{o - c} closing parentheses."
        else
          "missing #{c - o} opening parentheses."
        end

      ExIRC.Client.msg(client, :privmsg, channel, "Nope, #{message}")
    end

    {:noreply, client}
  end

  def handle_info({:received, msg, _from, _channel}, client) do
    Regex.scan(~r"[\(\)]", msg)
    |> Enum.flat_map(& &1)
    |> Enum.map(&update/1)

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
