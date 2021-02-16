defmodule Ircois.Plugins.Tweets do
  use Ircois.Plugin.Macros

  help do
    [
      {"/", "Prints out the contents of Twitter links."}
    ]
  end

  react ~r"https?:\/\/twitter\.com\/(?:#!\/)?(\w+)\/status(?:es)?\/(?<id>\d+)(?:\/.*)?", e do
    tweet_id = e.captures["id"]
    tweet_content = get_tweet_content(tweet_id)

    if tweet_content do
      {:reply, tweet_content, e.state}
    else
      {:noreply, e.state}
    end
  end

  defp get_tweet_content(id) do
    config_auth()

    case ExTwitter.lookup_status(id, trim_user: true, tweet_mode: :extended) do
      [tweet] ->
        tweet.full_text |> String.replace("\n", " ")

      _ ->
        nil
    end
  end

  defp config_auth() do
    credentials = Ircois.Config.read_config().twitter

    ExTwitter.configure(
      consumer_key: credentials["consumer_key"],
      consumer_secret: credentials["consumer_secret"],
      access_token: credentials["access_token"],
      access_token_secret: credentials["access_token_secret"]
    )
  end
end
