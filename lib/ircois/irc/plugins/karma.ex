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

  defstate do
    %{}
  end

  react ~r/!(?<sub>.+)(?<op>\+\+|--)/, e do
    r = Regex.named_captures(~r/!(?<sub>.+)(?<op>\+\+|--)/, e.message)
    delta = if r["op"] == "--", do: -1, else: 1
    state = Map.update(e.state, r["sub"], delta, fn k -> k + delta end)
    {:noreply, state}
  end

  react ~r/karma\s(?<sub>.+)/i, e do
    r = Regex.named_captures(~r/karma\s(?<sub>.+)/i, e.message)

    if Map.has_key?(e.state, r["sub"]) do
      {:reply, "'#{r["sub"]}' has #{Map.get(e.state, r["sub"])} karma points.", e.state}
    else
      {:reply, "'#{r["sub"]}' has 0 karma points.", e.state}
    end
  end

  dm ~r/karmalist/i, e do
    responses =
      e.state
      |> Enum.to_list()
      |> Enum.sort_by(fn {_s, k} -> k end)
      |> Enum.take(15)
      |> Enum.zip(1..Enum.count(e.state))
      |> Enum.map(fn {{s, k}, i} -> "#{i}) #{s}: #{k} points" end)
      |> Enum.join("\n")

    {:reply, "Karma top 15\n#{responses}", e.state}
  end
end
