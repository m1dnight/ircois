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

  hear ~r/^[\W \t]*(\W*)feest(je)*[ \t\W]*/i, e do
    {:reply, "💃🎉🎊🥳💥", e.state}
  end
end
