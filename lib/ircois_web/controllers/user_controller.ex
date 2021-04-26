defmodule IrcoisWeb.UserController do
  use IrcoisWeb, :controller

  def user(conn, %{"user" => username}) do
    cfg = Ircois.Config.read_config()
    default_channel = hd(cfg.channels)

    IO.inspect default_channel
    IO.inspect username
    # Activity per hour.
    buckets = Ircois.Statistics.active_hours(username, default_channel)

    render(conn, "index.html", activity_buckets: buckets)
  end
end
