defmodule Ircois.Plugins.Version do
  use Ircois.Plugin.Macros

  help do
    [
      {
        "`version`",
        "Prints out the current version of the build in DM."
      }
    ]
  end

  dm ~r/^[ \t]*version[ \t]*/i, e do
    {:reply, "Current version: #{Application.spec(:ircois, :vsn) |> to_string()}", e.state}
  end
end
