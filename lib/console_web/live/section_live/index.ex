defmodule ReflectOS.ConsoleWeb.SectionLive.Index do
  use ReflectOS.ConsoleWeb, :live_view

  alias ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.Settings.SectionStore

  @impl true
  def mount(_params, _session, socket) do
    sections =
      SectionStore.list()
      |> Enum.map(&format_section/1)

    socket =
      socket
      |> stream(:sections, sections)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Sections")
    |> assign(:section, nil)
  end

  defp apply_action(socket, :configure, %{"id" => id}) do
    section = SectionStore.get(id)

    socket
    |> assign(:page_title, "Configure #{section.name}")
    |> assign(:section, section)
  end

  defp apply_action(socket, :rename, %{"id" => id}) do
    section = SectionStore.get(id)

    socket
    |> assign(:page_title, "Rename #{section.name}")
    |> assign(:section, section)
  end

  defp apply_action(socket, :delete, %{"id" => id}) do
    section = SectionStore.get(id)

    socket
    |> assign(:page_title, "Delete #{section.name}")
    |> assign(:section, section)
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Section")
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.SectionLive.ConfigFormComponent, {:saved, section}},
        socket
      ) do
    {:noreply, stream_insert(socket, :sections, format_section(section))}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.SectionLive.RenameFormComponent, {:saved, section}},
        socket
      ) do
    {:noreply, stream_insert(socket, :sections, format_section(section))}
  end

  @impl true
  def handle_info(
        {ReflectOS.ConsoleWeb.SectionLive.NewFormWizard, {:saved, section}},
        socket
      ) do
    {:noreply, stream_insert(socket, :sections, format_section(section))}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    section = socket.assigns[:section]

    :ok = SectionStore.delete(section.id)

    socket =
      socket
      |> stream_delete(:sections, format_section(section))
      |> put_flash(:info, "Section deleted successfully")
      |> push_patch(to: ~p"/sections")

    {:noreply, socket}
  end

  defp format_section(%Section{module: module} = section) do
    %{name: type, icon: icon} = module.section_definition()

    section
    |> Map.from_struct()
    |> Map.put(:type, type)
    |> Map.put(:icon, icon)
  end
end
