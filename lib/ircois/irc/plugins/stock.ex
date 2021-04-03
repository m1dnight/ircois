defmodule Ircois.Plugins.Stonks do
  use Ircois.Plugin.Macros
  import Number.Currency

  help do
    [
      {
        "`$<symbol>`",
        "Prints the current value of the symbol if it exists."
      }
    ]
  end

  hear ~r/^[ \t]*\$(?<sym>.+)[ \t]*/i, e do
    response = get_values(e.captures["sym"])
    {:reply, response, e.state}
  end

  def get_values(symbol) do
    api_key = Ircois.Config.read_config().alphavantage

    url =
      "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=#{symbol}&apikey=#{api_key}"

    with {:ok, r} <- HTTPoison.get(url),
         {:ok, json} <- r.body |> Poison.decode(),
         data <- Map.get(json, "Global Quote"),
         _sym <- Map.get(data, "01. symbol"),
         {qot, ""} <- Map.get(data, "05. price") |> Float.parse(),
         qot <- Float.floor(qot, 2) |> Number.Currency.number_to_currency(unit: ""),
         {chg, ""} <- Map.get(data, "09. change") |> Float.parse(),
         chg <- Float.floor(chg, 2),
         dat <- Map.get(data, "07. latest trading day"),
         {curr, name} <- get_meta_data(symbol) do
      "#{name} | #{qot} #{curr} | #{chg}% | #{dat}"
    else
      _e -> nil
    end
  end

  def get_meta_data(symbol) do
    api_key = Ircois.Config.read_config().alphavantage

    url =
      "https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=#{symbol}&apikey=#{
        api_key
      }"

    with {:ok, r} <- HTTPoison.get(url),
         {:ok, json} <- r.body |> Poison.decode(),
         [data | _] <- Map.get(json, "bestMatches"),
         cur <- Map.get(data, "8. currency"),
         nme <- Map.get(data, "2. name") do
      {cur, nme}
    else
      _e -> nil
    end
  end
end
