defmodule Ircois.Plugins.Party do
  use Ircois.Plugin.Macros

  help do
    [
      {
        "`feest`",
        "Bouwt een feestje."
      }
    ]
  end

  react ~r/^[\W \t]*(\W*)feest(je)*[ \t\W]*/i, e, probability: 0.5 do
    {:reply, "💃🎉🎊🥳💥", e.state}
  end
end
