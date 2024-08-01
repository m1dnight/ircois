defmodule Ircois.Connection.ConnectionHandler do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init([client, config]) do
    ExIRC.Client.add_handler(client, self())
    # ExIRC.Client.connect!(client, config.server, config.port)
    {:ok, {client, config}}
  end

  def handle_info({:connected, server, port}, {client, config}) do
    Logger.debug("Connected to #{server}:#{port}")
    ExIRC.Client.logon(client, config.password, config.nickname, config.user, config.user)
    {:noreply, {client, config}}
  end

  def handle_info(:disconnected, {client, config}) do
    Logger.error("Server disconnected!")
    # Only crash after 10 seconds to give the remote server to restart.
    Process.send_after(self(), :restart_connection, 10_000)

    {:noreply, {client, config}}
  end

  def handle_info(:restart_connection, state) do
    {:stop, :normal, state}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
