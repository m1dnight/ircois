defmodule Ircois.Plugins.Nicktracker do
  use Ircois.Plugin.Macros

  help do
    [
      {
        "*",
        "Keeps track of the nicknames of everyone."
      }
    ]
  end

  rename e do
    Ircois.Data.add_alias(%{:name => e.old, :alias => e.new})
    {:noreply, e.state}
  end
end
