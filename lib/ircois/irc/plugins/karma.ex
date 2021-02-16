defmodule Ircois.Plugins.Karma do
  use Ircois.Plugin.Macros
  require Logger

  help do
    [
      {"!<subject> ++/--", "Increases (++) or decreases (--) the karma of <subject>."},
      {
        "karma <subject>",
        "Prints the karma of <subject> in the main channel."
      },
      {"karmalist", "Prints out the top 15 of karma points in a private message."}
    ]
  end


  react ~r/[ \t]*!(?<sub>.+)(?<op>\+\+|--)[ \t]*/, e do
    delta = if e.captures["op"] == "--", do: -1, else: 1
    Logger.debug "Increasing karma for #{e.captures["sub"]} by #{delta}"
    Ircois.Data.add_karma(e.captures["sub"], delta)
    {:noreply, e.state}
  end

  react ~r/^karma\s(?<sub>.+)/i, e do
    karma = Ircois.Data.get_karma(e.captures["sub"])
    {:reply, "'#{e.captures["sub"]}' has #{karma} karma points.", e.state}

  end

  dm ~r/^[ \t]*karmalist[ \t]*$/i, e do
    responses =
      Ircois.Data.karma_top(15)
      |> Enum.sort_by(fn k -> k.karma end)
      |> Enum.zip(1..15)
      |> Enum.map(fn {k, i} -> "#{i}) #{k.subject}: #{k.karma} points" end)
      |> Enum.join("\n")

    {:reply, "Karma top 15\n#{responses}", e.state}
  end
end
