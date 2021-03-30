defmodule Ircois.Plugins.UwMoeder do
  use Ircois.Plugin.Macros

  react ~r/.*\sis\s(.+\s)?een(?<wat>(\s*[a-zA-Z]+\s*)+)/, e do
    wat = e.captures["wat"]

    if :rand.uniform() > 0.0 do
      w = String.trim(wat)
      {:reply, "Uw moeder is een #{w}.", e.state}
    else
      {:noreply, e.state}
    end
  end
end
