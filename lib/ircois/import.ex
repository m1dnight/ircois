defmodule Ircois.Import do
  def import(file, channel) do
    {:ok, res} = File.read!(file) |> WeechatParser.try_parse_log()

    res
    |> Enum.filter(fn x -> x.type == :message end)
    |> Enum.chunk_every(1000)
    |> Enum.each(fn chunk ->
      spawn(fn ->
        Enum.map(chunk, fn %{timestamp: ts, from: f, message: m} ->
          for url <- Ircois.Plugins.Logger.filter_url(m) do
            Ircois.Data.store_url(%{:from => f, :url => url})
          end

          Ircois.Data.store_message(%{from: f, content: m, channel: "#elixir", when: ts})
        end)
      end)
    end)
  end
end
