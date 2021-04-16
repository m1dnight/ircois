defmodule Ircois.Plugins.Remember do
  use Ircois.Plugin.Macros
  alias Ircois.Data

  help do
    [
      {
        "`remember <subject> is <value>`",
        "Remembers that <subject> is <value>."
      },
      {"`<subject>?`", "If <subject> is a known alias, prints out its value."}
    ]
  end

  defstate do
    %{}
  end

  react ~r/^[ \t]*remember (?<sub>.+) is (?<exp>.+)[ \t]*/i, e do
    sub = e.captures["sub"]
    exp = e.captures["exp"]
    Data.remember(sub, exp)
    {:reply, "I noted that '#{sub}' is '#{exp}'", e.state}
  end

  react ~r/^[ \t]*what[ \t]*is[ \t]*(?<sub>.+?)[ \t]*\?[ \t]*/i, e do
    sub = e.captures["sub"]

    case Data.known?(sub) do
      nil ->
        {:noreply, e.state}

      d ->
        {:reply, "#{sub} is #{d}", e.state}
    end
  end
end
