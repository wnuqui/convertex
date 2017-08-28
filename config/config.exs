# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :convertex,
  ecto_repos: [Convertex.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :convertex, ConvertexWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Hq0LWgpUzXoJRBwDcsX1w10I1REYjUobPuxFkJMyMn7LDZ3WExNNAoCfWAFoKDev",
  render_errors: [view: ConvertexWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Convertex.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
