defmodule ReflectOS.ConsoleWeb.LayoutManagerLive.Index do
  use ReflectOS.ConsoleWeb, :live_view

  alias ReflectOS.Kernel.LayoutManager
  alias ReflectOS.Kernel.Settings.LayoutManagerStore

  @impl true
  def mount(_params, _session, socket) do
    layout_managers =
      LayoutManagerStore.list()
      |> Enum.map(&format_layout_manager/1)

    socket =
      socket
      |> stream(:layout_managers, layout_managers)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Layout Managers")
    |> assign(:layout_manager, nil)
  end

  defp apply_action(socket, :configure, %{"id" => id}) do
    layout_manager = LayoutManagerStore.get(id)

    socket
    |> assign(:page_title, "Configure #{layout_manager.name}")
    |> assign(:layout_manager, layout_manager)
  end

  defp apply_action(socket, :rename, %{"id" => id}) do
    layout_manager = LayoutManagerStore.get(id)

    socket
    |> assign(:page_title, "Rename #{layout_manager.name}")
    |> assign(:layout_manager, layout_manager)
  end

  defp apply_action(socket, :delete, %{"id" => id}) do
    layout_manager = LayoutManagerStore.get(id)

    socket
    |> assign(:page_title, "Delete #{layout_manager.name}")
    |> assign(:layout_manager, layout_manager)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New LayoutManager")
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutManagerLive.ConfigFormComponent, {:saved, layout_manager}},
        socket
      ) do
    {:noreply, stream_insert(socket, :layout_managers, format_layout_manager(layout_manager))}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutManagerLive.RenameFormComponent, {:saved, layout_manager}},
        socket
      ) do
    {:noreply, stream_insert(socket, :layout_managers, format_layout_manager(layout_manager))}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutManagerLive.NewFormWizard, {:saved, layout_manager}},
        socket
      ) do
    {:noreply, stream_insert(socket, :layout_managers, format_layout_manager(layout_manager))}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    layout_manager = socket.assigns[:layout_manager]

    :ok = LayoutManagerStore.delete(layout_manager.id)

    socket =
      socket
      |> stream_delete(:layout_managers, format_layout_manager(layout_manager))
      |> put_flash(:info, "LayoutManager deleted successfully")
      |> push_patch(to: ~p"/layout-managers")

    {:noreply, socket}
  end

  defp format_layout_manager(%LayoutManager{module: module} = layout_manager) do
    %{name: type, icon: icon} = module.layout_manager_definition()

    layout_manager
    |> Map.from_struct()
    |> Map.put(:type, type)
    |> Map.put(:icon, icon)
  end
end
