defmodule Ircois.Plugins.Remember do
  use Ircois.Plugin.Macros

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
    state = Map.put(e.state, sub, exp)
    {:reply, "I noted that '#{sub}' is '#{exp}'", state}
  end

  react ~r/^[ \t]*(?<sub>.+?)[ \t]*\?[ \t]*/, e do
    sub = e.captures["sub"]

    if Map.has_key?(e.state, sub) do
      {:reply, "#{sub} is '#{Map.get(e.state, sub)}'", e.state}
    else
      IO.puts("Key: `#{sub}` not found in #{inspect(e.state)}")
      {:noreply, e.state}
    end
  end
end