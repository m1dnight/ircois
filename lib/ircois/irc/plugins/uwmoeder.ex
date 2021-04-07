defmodule Ircois.Plugins.UwMoeder do
  use Ircois.Plugin.Macros

  react ~r/.*\sis\s(.+\s)?een(?<wat>(\s*[a-zA-Z]+\s*)+)/, e, probability: 0.05 do
    wat = e.captures["wat"]

    w = String.trim(wat)
    {:reply, "Uw moeder is een #{w}.", e.state}
  end
end
