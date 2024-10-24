defmodule ReflectOS.ConsoleWeb.LayoutLive.Index do
  use ReflectOS.ConsoleWeb, :live_view

  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Settings.LayoutStore

  @impl true
  def mount(_params, _session, socket) do
    layouts =
      LayoutStore.list()
      |> Enum.map(&format_layout/1)

    socket =
      socket
      |> stream(:reflectos_layouts, layouts)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Layouts")
    |> assign(:reflectos_layout, nil)
  end

  defp apply_action(socket, :configure, %{"id" => id}) do
    layout = LayoutStore.get(id)

    socket
    |> assign(:page_title, "Configure #{layout.name}")
    |> assign(:reflectos_layout, layout)
  end

  defp apply_action(socket, :manage, %{"id" => id}) do
    layout = LayoutStore.get(id)

    socket
    |> assign(:page_title, "Manage #{layout.name}")
    |> assign(:reflectos_layout, layout)
  end

  defp apply_action(socket, :rename, %{"id" => id}) do
    layout = LayoutStore.get(id)

    socket
    |> assign(:page_title, "Rename #{layout.name}")
    |> assign(:reflectos_layout, layout)
  end

  defp apply_action(socket, :delete, %{"id" => id}) do
    layout = LayoutStore.get(id)

    socket
    |> assign(:page_title, "Delete #{layout.name}")
    |> assign(:reflectos_layout, layout)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Layout")
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutLive.ConfigFormComponent, {:saved, layout}},
        socket
      ) do
    {:noreply, stream_insert(socket, :reflectos_layouts, format_layout(layout))}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutLive.RenameFormComponent, {:saved, layout}},
        socket
      ) do
    {:noreply, stream_insert(socket, :reflectos_layouts, format_layout(layout))}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutLive.ManageFormComponent, {:saved, layout}},
        socket
      ) do
    {:noreply, stream_insert(socket, :reflectos_layouts, format_layout(layout))}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutLive.NewFormWizard, {:saved, layout}},
        socket
      ) do
    {:noreply, stream_insert(socket, :reflectos_layouts, format_layout(layout))}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    layout = socket.assigns[:reflectos_layout]

    :ok = LayoutStore.delete(layout.id)

    socket =
      socket
      |> stream_delete(:reflectos_layouts, format_layout(layout))
      |> put_flash(:info, "Layout deleted successfully")
      |> push_patch(to: ~p"/layouts")

    {:noreply, socket}
  end

  defp format_layout(%Layout{module: module} = layout) do
    %{name: type, icon: icon} = module.layout_definition()

    layout
    |> Map.from_struct()
    |> Map.put(:type, type)
    |> Map.put(:icon, icon)
  end
end
