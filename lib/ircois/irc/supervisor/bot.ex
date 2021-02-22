defmodule Supervisor.Bot do
  use Supervisor

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(client_name) do
    children = [
      worker(Bot.Logger, [client_name]),
      worker(Bot.Ohai, [client_name]),
      # worker(Bot.Pedantic, [client_name]),
      worker(Bot.Karma, [client_name]),
      # worker(Bot.Parentheses, [client_name]),
      # worker(Bot.Sentiment, [client_name]),
      worker(Bot.UwMoeder, [client_name]),
      worker(Bot.Bitcoin, [client_name]),
      # worker(Bot.Seen, [client_name])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
