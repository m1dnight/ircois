# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :ircois,
  ecto_repos: [Ircois.Repo]

# Configures the endpoint
config :ircois, IrcoisWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "M6gD+aU4TpsQqACDsnob1WZmxzVUslZNn4fqhDQISE6G9XVFnIEXWBg1ZCTaxGo+",
  render_errors: [view: IrcoisWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ircois.PubSub,
  live_view: [signing_salt: "1ifhtLMl"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
