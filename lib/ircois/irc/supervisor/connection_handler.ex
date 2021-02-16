defmodule ConnectionHandler do
  require Logger

  def start_link(client, state \\ %Ircois.Config{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    Logger.debug("Connecting to #{state.server}:#{state.port}")
    ExIRC.Client.add_handler(state.client, self())
    ExIRC.Client.connect!(state.client, state.server, state.port)
    {:ok, state}
  end

  def handle_info({:connected, _server, _port}, state) do
    Logger.debug("Connected to #{state.server}:#{state.port}")
    ExIRC.Client.logon(state.client, state.password, state.nickname, state.user, state.user)
    {:noreply, state}
  end

  def handle_info(:disconnected, state) do
    Logger.debug("Disconnected from #{state.server}:#{state.port}")
    ExIRC.Client.connect!(state.client, state.server, state.port)
    {:noreply, state}
  end

  # Catch-all for messages you don't care about
  def handle_info(msg, state) do
    Logger.debug(inspect(msg))
    {:noreply, state}
  end
end
