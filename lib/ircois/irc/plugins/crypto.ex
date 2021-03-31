defmodule Ircois.Plugins.Crypto do
  use Ircois.Plugin.Macros
  import Number.Currency

  help do
    [
      {
        "!btc",
        "Prints the current value of Bitcoin, Litecoin, and Ethereum."
      }
    ]
  end

  hear ~r/^[ \t]*!btc[ \t]*/i, e do
    response = get_values(e.config.coinmarketcap)
    {:reply, response, e.state}
  end

  defp get_values(api_key) do
    url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest"
    headers = ["X-CMC_PRO_API_KEY": api_key]
    params = %{slug: "bitcoin,ethereum,litecoin", convert: "USD"}

    with {:ok, r} <- HTTPoison.get(url, headers, params: params),
         {:ok, json} <- r.body |> Poison.decode(),
         data <- Map.get(json, "data"),
         btc_data <- Map.get(data, "1"),
         eth_data <- Map.get(data, "1027"),
         ltc_data <- Map.get(data, "2") do
      btc_value = btc_data |> Map.get("quote") |> Map.get("USD") |> Map.get("price")
      eth_value = eth_data |> Map.get("quote") |> Map.get("USD") |> Map.get("price")
      ltc_value = ltc_data |> Map.get("quote") |> Map.get("USD") |> Map.get("price")

      "Bitcoin: #{btc_value |> number_to_currency}, Litecoin: #{ltc_value |> number_to_currency}, Ethereum: #{
        eth_value |> number_to_currency
      }"
    end
  end
end
