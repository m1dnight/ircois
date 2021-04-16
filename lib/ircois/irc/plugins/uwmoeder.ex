defmodule Ircois.Plugins.UwMoeder do
  use Ircois.Plugin.Macros

  react ~r/.*\sis\s(.+\s)?(?<wat>een(\s*[a-zA-Z]+)+)/, e, probability: 0.2 do
    wat = e.captures["wat"]

    w = String.trim(wat)
    {:reply, "Uw moeder is #{w}.", e.state}
  end
end
