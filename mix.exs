defmodule ReflectOS.Console.MixProject do
  use Mix.Project

  @version Path.join(__DIR__, "VERSION")
           |> File.read!()
           |> String.trim()

  @source_url "https://github.com/Reflect-OS/console"

  def project do
    [
      app: :reflect_os_console,
      description: description(),
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ReflectOS.Console.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp description do
    """
    ReflectOS Console is a web app that allows users to arrange their ReflectOS
    dashboard, configure section, switch layouts and much more.  It ships with the
    pre-built ReflectOS firmware.
    """
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.6"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev, targets: [:host]},
      # TODO bump on release to {:phoenix_live_view, "~> 1.0.0"},
      {:phoenix_live_view, "~> 1.0.0-rc.7"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev && Mix.target() == :host},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev && Mix.target() == :host},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},

      # ReflectOS
      {:reflect_os_kernel, "~> 0.10.0"},
      # Only bring in core for dev
      {:reflect_os_core, "~> 0.10.0", only: :dev},
      {:nerves_time_zones, "~> 0.3.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind reflect_os_console", "esbuild reflect_os_console"],
      "assets.deploy": [
        "tailwind reflect_os_console --minify",
        "esbuild reflect_os_console --minify",
        "phx.digest"
      ]
    ]
  end

  defp docs do
    [
      name: "ReflectOS Console",
      source_url: "https://github.com/Reflect-OS/console",
      homepage_url: "https://github.com/Reflect-OS/console",
      source_ref: "v#{@version}",
      extras: ["README.md"],
      main: "readme"
    ]
  end

  defp package do
    [
      files: package_files(),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp package_files,
    do: [
      "lib",
      ".formatter.exs",
      "CHANGELOG.md",
      "LICENSE",
      "mix.exs",
      "README.md",
      "VERSION",
      "priv",
      "assets"
    ]
end
