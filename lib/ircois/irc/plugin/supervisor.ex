defmodule Ircois.Plugin.Supervisor do
  use Supervisor

  alias Ircois.Plugin.Runner

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init([exirc_client, config]) do
    # Create runner child specs for all the modules in the config file.
    children =
      config
      |> Map.get(:modules)
      |> Enum.map(fn module ->
        Supervisor.child_spec({Runner, [module, exirc_client, config]}, id: module)
      end)

    children =
      [
        {Ircois.Plugin.Manager, [exirc_client, config]}
      ] ++ children

    Supervisor.init(children, strategy: :one_for_all)
  end
end
