defmodule Ircois.Plugins.Zelluf do
  use Ircois.Plugin.Macros

  react ~r/.*\sis\s(.+\s)?een(?<wat>(\s*[a-zA-Z]+\s*)+)/i, e, probability: 0.1 do
    wat = e.captures["wat"]

    w = String.trim(wat)
    {:reply, "Zelluf een #{w}.", e.state}
  end
end
