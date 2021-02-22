defmodule Bot.Bitcoin do
  require Logger
  alias Ircois.Config
  import Number.Currency

  @moduledoc """
  This plugin keeps track of karma of things.

  It listens to the commands `<subject>++`.
  """

  ##############################################################################
  # GenServer

  def start_link(client) do
    GenServer.start_link(__MODULE__, [client])
  end

  def init([client]) do
    Logger.debug("Initializing plugin #{__MODULE__}")
    ExIRC.Client.add_handler(client, self())
    {:ok, client}
  end

  ##############################################################################
  # Event Handlers

  # If this is a command, handle it.
  def handle_info({:received, msg = <<"btc!"::utf8, _::bitstring>>, _from, channel}, client) do
    response = get_quote()

    ExIRC.Client.msg(client, :privmsg, channel, response)

    {:noreply, client}
  end

  # Catch-all for messages you don't care about
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp get_quote() do
    api_key = Config.read_config("config.json") |> Map.get(:coinmarketcap)
    url = "https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest"
    headers = ["X-CMC_PRO_API_KEY": api_key]

    params = %{slug: "bitcoin,ethereum,litecoin", convert: "USD"}

    with {:ok, r} <- HTTPoison.get(url, headers, params: params),
         {:ok, json} <- r.body |> Poison.decode() do
      data = Map.get(json, "data")

      btc_value = Map.get(data, "1") |> Map.get("quote") |> Map.get("USD") |> Map.get("price")
      eth_value = Map.get(data, "1027") |> Map.get("quote") |> Map.get("USD") |> Map.get("price")
      ltc_value = Map.get(data, "2") |> Map.get("quote") |> Map.get("USD") |> Map.get("price")

      "Bitcoin: #{btc_value |> number_to_currency}, Litecoin: #{ltc_value |> number_to_currency}, Ethereum: #{
        eth_value |> number_to_currency
      }"
    end
  end
end
