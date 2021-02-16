defmodule Ircois.Plugins.Logger do
  use Ircois.Plugin.Macros

  help do
    {"Logger", "Logs all the messages and shows them through the webinterface."}
  end

  react ~r/.*/, e do
    # Log messages.
    Ircois.Data.store_message(%{:from => e.from, :content => e.message, :channel => e.channel})

    # Log urls.
    for url <- filter_url(e.message) do
      Ircois.Data.store_url(%{:from => e.from, :url => url})
    end
    {:noreply, e.state}
  end

  #############################################################################
  # Helpers
  def filter_url(string) do
    ~r"http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"
    |> Regex.scan(string)
    |> Enum.flat_map(& &1)
  end
end
