defmodule ReflectOS.ConsoleWeb.DashboardLive.Index do
  alias ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.Settings.SectionStore
  alias ReflectOS.Kernel.Settings.LayoutStore

  use ReflectOS.ConsoleWeb, :live_view
  @impl true
  def mount(_params, _session, socket) do
    active_layout = LayoutStore.get("default")

    socket =
      socket
      |> assign(:active_layout, active_layout)
      |> assign_location_sections()

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Dashboard")
    |> assign(:sectiom, nil)
  end

  defp apply_action(socket, :manage, _params) do
    socket
    |> assign(:page_title, "Manage Sections")
  end

  defp apply_action(socket, :configure, _params) do
    socket
    |> assign(:page_title, "Configure Active Layout")
  end

  defp apply_action(socket, :section_configure, %{"id" => section_id}) do
    section = SectionStore.get(section_id)

    socket
    |> assign(:page_title, "Configure #{section.name}")
    |> assign(:section, section)
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutLive.ConfigFormComponent, {:saved, layout}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:active_layout, layout)
     |> assign_location_sections()}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.LayoutLive.ManageFormComponent, {:saved, layout}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:active_layout, layout)
     |> assign_location_sections()}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.SectionLive.ConfigFormComponent, {:saved, _section}},
        socket
      ) do
    {:noreply,
     socket
     |> assign(:section, nil)
     |> assign_location_sections()}
  end

  defp assign_location_sections(%{assigns: %{active_layout: layout}} = socket) do
    %{locations: locations} = layout.module.layout_definition()

    location_sections =
      locations
      |> Enum.map(fn %{key: key, label: label} ->
        sections =
          if layout.sections[key] == nil do
            []
          else
            layout.sections[key]
            |> Enum.map(fn id ->
              section = SectionStore.get(id)
              format_section(section)
            end)
          end

        {label, sections}
      end)

    socket
    |> assign(:location_sections, location_sections)
  end

  defp format_section(%Section{module: module} = section) do
    %{name: type, icon: icon} = module.section_definition()

    section
    |> Map.from_struct()
    |> Map.put(:type, type)
    |> Map.put(:icon, icon)
  end
end
