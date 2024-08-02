# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :ircois,
  ecto_repos: [Ircois.Repo]

# Configures the endpoint
config :ircois, IrcoisWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "M6gD+aU4TpsQqACDsnob1WZmxzVUslZNn4fqhDQISE6G9XVFnIEXWBg1ZCTaxGo+",
  render_errors: [
    formats: [html: IrcoisWeb.ErrorHTML, json: IrcoisWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Ircois.PubSub,
  live_view: [signing_salt: "1ifhtLMl"]

# Configures Elixir's Logger
config :logger,
  backends: [:console]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :logger, :debug,
  path: "logs/debug.log",
  level: :debug

config :logger, :error,
  path: "logs/error.log",
  level: :error

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# tz
config :elixir, :time_zone_database, Tz.TimeZoneDatabase

config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :esbuild,
  version: "0.12.17",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
