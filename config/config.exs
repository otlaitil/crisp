# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :crisp,
  ecto_repos: [Crisp.Repo]

# Configures the endpoint
config :crisp, CrispWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "hG2SO8RSFW76Du5FaC7V01jjpWJQlNR0/fLDm5GGeKe62D7IZG0WZNJK6dUF3Bbo",
  render_errors: [view: CrispWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Crisp.PubSub,
  live_view: [signing_salt: "v4afDfXh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
