defmodule Supervisor.Connection do
  require Logger
  use Supervisor

  def start_link(state \\ []) do
    Logger.debug("Starting connection to server.")
    Supervisor.start_link(__MODULE__, state)
  end

  def init(_state) do
    client = Ircois.ExIRC.Client

    children = [
      worker(ExIRC.Client, [[debug: false], [name: client]]),
      worker(ConnectionHandler, [client, Ircois.Config.read_config("config.json")]),
      worker(LoginHandler, [client, Ircois.Config.read_config("config.json")]),
      worker(Supervisor.Bot, [client])
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
