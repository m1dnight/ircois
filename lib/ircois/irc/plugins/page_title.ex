defmodule Ircois.Plugins.PageTitle do
  use Ircois.Plugin.Macros

  help do
    [
      {"/", "Prints out the page title of pasted links."}
    ]
  end

  react ~r"http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+", e do
    r = ~r"http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+"

    titles = Regex.scan(r, e.message)
    |> Enum.flat_map(& &1)
    |> Enum.map(&get_page_title/1)
    |> Enum.join("\n")

    {:reply, titles, e.state}
  end

  def get_page_title(url) do
    with {:ok, r = %{status_code: 200}} <- HTTPoison.get(url),
         %{"title" => t} <- Regex.named_captures(~r/\<title\>(?<title>.+)<\/title\>/, r.body),
         clean <- t |> String.replace("\n", "") |> String.slice(0, 80) do
      clean
    else
      _e -> nil
    end
  end
end
