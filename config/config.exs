# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :reflect_os_console,
  namespace: ReflectOS.Console,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :reflect_os_console, ReflectOS.ConsoleWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ReflectOS.ConsoleWeb.ErrorHTML, json: ReflectOS.ConsoleWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ReflectOS.Console.PubSub,
  live_view: [signing_salt: "dx3+SiJX"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  reflect_os_console: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.10",
  reflect_os_console: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :reflect_os_console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure system defaults for running just the console (not from the firmware)
config :reflect_os_kernel, :system,
  time_format: "%-I:%M %p",
  viewport_size: {1080, 1920},
  timezone: "America/New_York"

config :reflect_os_kernel, :settings, data_directory: "./data"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
