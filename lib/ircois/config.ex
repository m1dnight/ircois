defmodule Ircois.Config do
  defstruct channels: [],
            nickname: nil,
            password: nil,
            port: nil,
            server: nil,
            user: nil,
            client: nil,
            coinmarketcap: nil,
            modules: []

  require Logger

  def default_config() do
    %Ircois.Config{
      channels: ["#somechannel"],
      nickname: "foobar",
      password: "supersecret",
      port: 1234,
      server: "irc.example.com",
      user: "irCois The Second",
      modules: [Bot.Logger, Bot.Ohai, Bot.Karma, Bot.UwMoeder, Bot.Bitcoin],
      coinmarketcap: "putapikeyhere"
    }
  end

  def read_config(path) do
    full_path = Path.absname(path)
    Logger.debug("Reading config #{inspect(full_path)}")

    cond do
      File.exists?(path) ->
        with {:ok, content} <- File.read(path),
             {:ok, map} <- Poison.decode(content) do
          map =
            map
            |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
            |> Enum.into(%{})
            |> Map.update(:modules, [], fn ms -> Enum.map(ms, &String.to_atom/1) end)

          struct(__MODULE__, map)
        else
          e ->
            Logger.error("Error reading config file #{inspect(full_path)}")
            e
        end

      true ->
        Logger.error("Configuration file #{inspect(full_path)} does not exist, creating default.")
        create_default_config("config.json")
        default_config()
    end
  end

  def create_default_config(path) do
    cfg = default_config() |> Poison.encode!()
    full_path = Path.absname("config.json")
    Logger.debug("Creating default configuration file #{inspect(full_path)}")
    File.write!(full_path, cfg)
  end
end
