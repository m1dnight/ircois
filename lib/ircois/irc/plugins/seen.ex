defmodule Ircois.Plugins.Seen do
  use Ircois.Plugin.Macros
  require Logger

  help do
    [
      {"`seen <nickname>`", "Prints out the last message and time by <nickname> ."}
    ]
  end

  hear ~r/^[ \t]*seen[ \t]*(?<sub>\w+)[ \t]*/i, e do
    case Ircois.Data.last_seen(e.channel, e.captures["sub"]) do
      nil ->
        {:reply, "Haven't seen that person.", e.state}

      m ->
        days = Timex.diff(Timex.now(), m.when, :days)
        hours = Timex.diff(Timex.now(), m.when, :hours)
        minutes = Timex.diff(Timex.now(), m.when, :minutes)
        seconds = Timex.diff(Timex.now(), m.when, :seconds)

        cond do
          days > 0 ->
            {:reply, "#{m.from} was last seen #{days} day(s) ago.", e.state}

          hours > 0 ->
            {:reply, "#{m.from} was last seen #{hours} hour(s) ago.", e.state}

          minutes > 0 ->
            {:reply, "#{m.from} was last seen #{minutes} minute(s) ago.", e.state}

          seconds > 5 ->
            {:reply, "#{m.from} was last seen #{seconds} second(s) ago.", e.state}

          true ->
            {:reply, "^ Look up.", e.state}
        end
    end
  end
end
