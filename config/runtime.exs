import Config

config :reflect_os_kernel, :system,
  time_format: "%-I:%M %p",
  viewport_size: {1080, 1920},
  timezone: "America/New_York"

config :reflect_os_kernel, :dashboard,
  sections: %{
    "default_date_time" => %{
      name: "Local Time and Date",
      module: ReflectOS.Core.Sections.DateTime,
      config: %{}
    },
    "default_weather" => %{
      name: "Local Weather",
      module: ReflectOS.Core.Sections.Weather,
      config: %{
        latitude: 43.2548,
        longitude: -70.8762,
        provider: ReflectOS.Core.Sections.Weather.Providers.PirateWeather,
        api_key: "HI2Wb1wooA3Ta2tkp2l1DIfrOM2wWLgL"
      }
    },
    "default_calendar" => %{
      name: "US Holiday Calendar",
      module: ReflectOS.Core.Sections.Calendar,
      config: %{
        ical_url_1:
          "https://calendar.google.com/calendar/ical/1862f976d2e292d6f738a6d0ebd94fcd0ab04e203785a8e0883b5da56a82b1eb%40group.calendar.google.com/private-012e8ca4362b2de90535f847e1bf4391/basic.ics"
      }
    }
    # "default_notifications" => %{
    #   name: "Notifications",
    #   module: ReflectOS.Core.Sections.Notifications,
    #   config: %{}
    # }
  },
  layouts: %{
    "default" => %{
      name: "System Default",
      module: ReflectOS.Core.Layouts.FourCorners,
      config: %{},
      sections: %{
        top_left: [
          "default_date_time"
        ]
        # top_right: [
        #   "default_weather"
        # ]
      }
    }
  },
  layout_managers: %{
    "default" => %{
      name: "Default Layout",
      module: ReflectOS.Core.LayoutManagers.Static,
      config: %{
        layout: "default"
      }
    }
  },
  layout_manager: "default"

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/console start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :reflect_os_console, ReflectOS.ConsoleWeb.Endpoint, server: true
end

if config_env() == :prod do
  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :reflect_os_console, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :reflect_os_console, ReflectOS.ConsoleWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :reflect_os_console, ReflectOS.ConsoleWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :reflect_os_console, ReflectOS.ConsoleWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.
end
