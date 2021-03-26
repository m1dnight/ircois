defmodule Supervisor.Bot do
  use Supervisor

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  def init(client_name) do
    children =
      Ircois.Config.read_config("config.json")
      |> Map.get(:modules)
      |> Enum.map(fn module ->
        worker(module, [client_name])
      end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
