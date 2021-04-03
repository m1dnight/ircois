defmodule Ircois.Plugins.Seen do
  use Ircois.Plugin.Macros
  require Logger

  help do
    [
      {"`seen <nickname>`", "Prints out the last message and time by <nickname> ."},
    ]
  end

  react ~r/[ \t]*!(?<sub>.+)(?<op>\+\+|--)[ \t]*/, e do
    delta = if e.captures["op"] == "--", do: -1, else: 1
    Logger.debug("Increasing karma for #{e.captures["sub"]} by #{delta}")
    Ircois.Data.add_karma(e.captures["sub"], delta)
    {:noreply, e.state}
  end

  react ~r/^karma\s(?<sub>.+)/i, e do
    karma = Ircois.Data.get_karma(e.captures["sub"])
    {:reply, "'#{e.captures["sub"]}' has #{karma} karma points.", e.state}
  end

  hear ~r/^[ \t]*seen[ \t]*(?<sub>\w+)[ \t]*/i, e do
    case Ircois.Data.last_seen(e.channel, e.captures["sub"]) do
      nil ->
        {:reply, "Haven't seen that person.", e.state}
      m ->
        {:reply, "#{m.from} was last seen around #{m.when |> Timex.format!("{RFC1123}")}", e.state}
    end

  end

end
