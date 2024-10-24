defmodule ReflectOS.ConsoleWeb.Router do
  use ReflectOS.ConsoleWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ReflectOS.ConsoleWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ReflectOS.ConsoleWeb do
    pipe_through :browser

    get "/about", PageController, :about

    live_session :app,
      on_mount: [
        ReflectOS.Console.LiveHooks.Nav
      ] do
      live "/", DashboardLive.Index, :index

      live "/dashboard/manage-layout", DashboardLive.Index, :manage
      live "/dashboard/configure-layout", DashboardLive.Index, :configure
      live "/dashboard/sections/:id/configure", DashboardLive.Index, :section_configure

      live "/sections", SectionLive.Index, :index
      live "/sections/new", SectionLive.Index, :new
      live "/sections/:id/configure", SectionLive.Index, :configure
      live "/sections/:id/rename", SectionLive.Index, :rename
      live "/sections/:id/delete", SectionLive.Index, :delete

      live "/layouts", LayoutLive.Index, :index
      live "/layouts/new", LayoutLive.Index, :new
      live "/layouts/:id/configure", LayoutLive.Index, :configure
      live "/layouts/:id/rename", LayoutLive.Index, :rename
      live "/layouts/:id/manage", LayoutLive.Index, :manage
      live "/layouts/:id/delete", LayoutLive.Index, :delete

      live "/layout-managers", LayoutManagerLive.Index, :index
      live "/layout-managers/new", LayoutManagerLive.Index, :new
      live "/layout-managers/:id/configure", LayoutManagerLive.Index, :configure
      live "/layout-managers/:id/rename", LayoutManagerLive.Index, :rename
      live "/layout-managers/:id/delete", LayoutManagerLive.Index, :delete

      live "/system/settings", SystemLive.Settings
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", ReflectOS.ConsoleWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:reflect_os_console, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ReflectOS.ConsoleWeb.Telemetry
    end
  end
end
