defmodule ReflectOS.Console.LiveHooks.Nav do
  import Phoenix.LiveView
  import Phoenix.Component, only: [assign: 2]

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_tab, :handle_params, &set_active_tab/3)}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {ReflectOS.ConsoleWeb.DashboardLive.Index, _} ->
          :dashboard

        {ReflectOS.ConsoleWeb.SectionLive.Index, _} ->
          :sections

        {ReflectOS.ConsoleWeb.LayoutLive.Index, _} ->
          :layouts

        {ReflectOS.ConsoleWeb.LayoutManagerLive.Index, _} ->
          :layout_managers

        {ReflectOS.ConsoleWeb.SystemLive.Settings, _} ->
          :settings

        _ ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
