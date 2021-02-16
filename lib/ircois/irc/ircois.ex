defmodule Ircois.Backend do
  use Supervisor
  alias Ircois.Config


  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @client ExIRC.Client
  @impl true
  def init(_args) do
    config = Config.read_config()

    children = [
      # IRC Connection
      %{id: @client, start: {ExIRC.Client, :start_link, [[], [name: @client]]}},
      {Ircois.Connection.ConnectionHandler, [@client, config]},
      {Ircois.Connection.LoginHandler, [@client, config]},
      {Ircois.Connection.MessageHandler, [@client, config]},
      {Ircois.Plugin.Supervisor, [@client, config]}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
