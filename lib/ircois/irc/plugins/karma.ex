defmodule Ircois.Plugins.Karma do
  use Ircois.Plugin.Macros

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


  react ~r/!(?<sub>.+)(?<op>\+\+|--)/, e do
    r = Regex.named_captures(~r/!(?<sub>.+)(?<op>\+\+|--)/, e.message)
    delta = if r["op"] == "--", do: -1, else: 1
    Ircois.Data.add_karma(r["sub"], delta)
    {:noreply, e.state}
  end

  react ~r/karma\s(?<sub>.+)/i, e do
    r = Regex.named_captures(~r/karma\s(?<sub>.+)/i, e.message)
    karma = Ircois.Data.get_karma(r["sub"])
    {:reply, "'#{r["sub"]}' has #{karma} karma points.", e.state}

  end

  dm ~r/karmalist/i, e do
    responses =
      Ircois.Data.karma_top(15)
      |> Enum.sort_by(fn k -> k.karma end)
      |> Enum.zip(1..15)
      |> Enum.map(fn {k, i} -> "#{i}) #{k.subject}: #{k.karma} points" end)
      |> Enum.join("\n")

    {:reply, "Karma top 15\n#{responses}", e.state}
  end
end
