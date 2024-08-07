defmodule Ircois.Plugins.Karma do
  use Ircois.Plugin.Macros
  require Logger

  help do
    [
      {"`,<subject> ++/--`", "Increases (++) or decreases (--) the karma of <subject>."},
      {
        "`karma <subject>`",
        "Prints the karma of <subject> in the main channel."
      },
      {"`karmalist`", "Returns a webpage that contains the current karma list."},
      {"`karmatop`", "Prints out the top 15 of karma points in a private message."}
    ]
  end

  react ~r/[ \t]*,(?<sub>.+)(?<op>\+\+|--)[ \t]*/, e do
    delta = if e.captures["op"] == "--", do: -1, else: 1
    Logger.debug("Increasing karma for #{e.captures["sub"]} by #{delta}")
    Ircois.Data.add_karma(e.captures["sub"] |> String.downcase(), delta)
    {:noreply, e.state}
  end

  react ~r/^,karma\s(?<sub>.+)/i, e do
    karma = Ircois.Data.get_karma(e.captures["sub"] |> String.downcase())
    {:reply, "'#{e.captures["sub"]}' has #{karma} karma points.", e.state}
  end

  # hear ~r/^[ \t]*karma[ \t]*list[ \t]*/i, e do
  #   url = "https://exbin.call-cc.be/api/snippet"

  #   karma_list = Ircois.Data.karma_top()

  #   content =
  #     karma_list
  #     |> Enum.sort_by(fn k -> k.karma end, &>=/2)
  #     |> Enum.zip(1..Enum.count(karma_list))
  #     |> Enum.map(fn {k, i} -> "#{i}) #{k.subject}: #{k.karma} points" end)
  #     |> (fn k -> ["Karma List" | k] end).()
  #     |> Enum.join("\n")

  #   with {:ok, json} <- Poison.encode(%{"content" => content, "private" => true}),
  #        {:ok, r = %{status_code: 200}} <-
  #          HTTPoison.post(url, json, [{"Content-Type", "application/json"}]),
  #        url <- r.body do
  #     {:reply, url, e.state}
  #   else
  #     _e -> {:reply, "An error occured!", e.state}
  #   end
  # end

  dm ~r/^[ \t]*,karmatop[ \t]*$/i, e do
    responses =
      Ircois.Data.karma_top(15)
      |> Enum.sort_by(fn k -> k.karma end, &>=/2)
      |> Enum.zip(1..15)
      |> Enum.map_join("\n", fn {k, i} -> "#{i}) #{k.subject}: #{k.karma} points" end)

    {:reply, "Karma top 15\n#{responses}", e.state}
  end
end
