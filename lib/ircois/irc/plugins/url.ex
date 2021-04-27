defmodule Ircois.Plugins.Url do
  use Ircois.Plugin.Macros

  help do
    [
      {"`website?`", "Prints out website."}
    ]
  end

  hear ~r/^[ \t]*website[ \t]*/i, e do
    url = Application.get_env(:ircois, IrcoisWeb.Endpoint)[:url][:host]
    {:reply, "https://#{url}/", e.state}
  end
end
