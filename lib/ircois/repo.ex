defmodule Ircois.Repo do
  use Ecto.Repo,
    otp_app: :ircois,
    adapter: Ecto.Adapters.Postgres
end
