defmodule Ircois.Config do
  require Logger

  defstruct channels: [],
            nickname: nil,
            password: nil,
            port: nil,
            server: nil,
            user: nil,
            client: nil,
            coinmarketcap: nil,
            modules: [],
            twitter: %{},
            alphavantage: nil

  @doc """
  Returns a default configuration file Elixir data structure.
  """
  def default_config do
    %Ircois.Config{
      channels: ["#ircois"],
      nickname: "ircois",
      password: "",
      port: 6667,
      server: "irc.freenode.net",
      user: "Cois",
      modules: [],
      coinmarketcap: "putapikeyhere",
      twitter: %{
        "access_token" => "api key",
        "access_token_secret" => "secret",
        "consumer_key" => "consumer key",
        "consumer_secret" => "consumer secret"
      },
      alphavantage: "apikeyhere"
    }
  end

  @doc """
  Reads the configuration file from the disk.
  """
  def read_config do
    path = Application.get_env(:ircois, :config)
    full_path = Path.absname(path)

    Logger.debug("Reading config #{inspect(full_path)}")

    if File.exists?(path) do
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
    else
      Logger.error("Configuration file #{inspect(full_path)} does not exist, creating default.")
      create_default_config(path)
      default_config()
    end
  end

  @doc """
  Creates a default configuration file and writes it to disk.
  """
  def create_default_config(path) do
    cfg = default_config() |> Poison.encode!()
    full_path = Path.absname(path)
    Logger.debug("Creating default configuration file #{inspect(full_path)}")
    File.write!(full_path, cfg)
  end
end
