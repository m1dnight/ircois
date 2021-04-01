defmodule Ircois.Plugins.Help do
  use Ircois.Plugin.Macros

  help do
    [
      {"`help`", "Prints out the help for all loaded plugins."},
      {"`info <plugin>`", "Show the specific commands for <plugin>."}
    ]
  end

  hear ~r/^[ \t]*info\s(?<plugin>.+)[ \t]*/i, e do
    sub = e.captures["plugin"] |> String.downcase()

    plugins = Ircois.Plugin.Manager.registered_plugins()

    reply =
      plugins
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(&String.split(&1, "."))
      |> Enum.map(&List.last/1)
      |> Enum.map(&String.downcase/1)
      |> Enum.zip(plugins)
      |> Enum.filter(&(sub == elem(&1, 0)))
      |> Enum.flat_map(fn {_, plugin} ->
        Ircois.Plugin.Manager.get_help(plugin)
      end)
      |> Enum.map(fn {cmd, help} ->
        "#{cmd}: #{help}"
      end)
      |> Enum.join("\n")

    if reply != "" do
      {:reply, reply, e.state}
    else
      {:reply, "No help for `#{sub}`.", e.state}
    end
  end

  hear ~r/^[ \t]*help[ \t]*$/i, e do
    plugins = Ircois.Plugin.Manager.registered_plugins()

    human_readable =
      plugins
      |> Enum.map(&Atom.to_string/1)
      |> Enum.map(&String.split(&1, "."))
      |> Enum.map(&List.last/1)

    help = """
    The bot has the following plugins loaded: #{human_readable |> Enum.join(", ")}. Type 'info <plugin>' to get help about a specific plugin.
    """

    {:reply, help, e.state}
  end
end
