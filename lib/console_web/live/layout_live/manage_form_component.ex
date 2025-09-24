defmodule ReflectOS.ConsoleWeb.LayoutLive.ManageFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias ReflectOS.Kernel.Layout.Changeset, as: LayoutChangeset
  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Settings.LayoutStore
  alias ReflectOS.Kernel.Settings.SectionStore

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="inline-flex items-center">
        {%{icon: icon} = @reflectos_layout.module.layout_definition()

        raw_icon(icon, class: "w-6 h-6 self-center mr-3")}
        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            Layout Sections
          </h5>
          <p class="font-thin">
            {@reflectos_layout.name}
          </p>
        </div>
      </div>

      <form phx-target={@myself} phx-submit="save" class="mt-5 space-y-8 bg-white">
        <div :for={{key, label, sections} <- @location_sections}>
          <h5 class="text-l font-medium text-gray-900 dark:text-white">
            {label}
          </h5>
          <hr class="h-px mb-3 bg-gray-200 border-0 dark:bg-gray-700" />
          <div :for={{section_id, index} <- Enum.with_index(sections)} class="flex items-center">
            <div class="w-full">
              <.input
                id={"sections[#{key}][#{index}]"}
                type="select"
                phx-change="change_section"
                phx-target={@myself}
                name={"sections[#{key}][#{index}]"}
                value={section_id}
                options={@section_options}
              />
            </div>

            <button
              phx-target={@myself}
              phx-click={"remove|#{key}|#{index}"}
              type="button"
              class="mb-3 ml-3 text-gray-400 bg-transparent hover:bg-gray-200 hover:text-gray-900 rounded-lg text-sm w-8 h-8 inline-flex items-center justify-center dark:hover:bg-gray-600 dark:hover:text-white"
            >
              <svg
                class="w-3 h-3"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 14 14"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"
                />
              </svg>
              <span class="sr-only">Remove Section</span>
            </button>
          </div>

          <.input
            id={"sections[#{key}][#{Enum.count(sections)}]"}
            type="select"
            prompt="-- Add New Section --"
            name={"sections[#{key}][new]"}
            phx-change="append_section"
            phx-target={@myself}
            options={@section_options}
            value={nil}
          />
        </div>
        <div class="mt-2 flex items-center justify-between gap-6">
          <.button phx-disable-with="Saving...">Save Layout</.button>
        </div>
      </form>
    </div>
    """
  end

  @impl true
  def update(%{reflectos_layout: %Layout{} = layout} = assigns, socket) do
    section_options =
      SectionStore.list()
      |> Enum.group_by(& &1.module)
      |> Enum.map(fn {module, sections} ->
        %{name: section_type} = module.section_definition()

        options =
          sections
          |> Enum.map(&{&1.name, &1.id})

        {section_type, options}
      end)

    %{locations: locations} = layout.module.layout_definition()

    location_sections =
      locations
      |> Enum.map(fn %{key: key, label: label} ->
        sections =
          if layout.sections[key] == nil do
            []
          else
            layout.sections[key]
          end

        {key, label, sections}
      end)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(location_sections: location_sections)
     |> assign(section_options: section_options)
     |> assign_new(:form, fn ->
       to_form(LayoutChangeset.change(layout), as: "layout")
     end)}
  end

  @impl true

  def handle_event(
        "append_section",
        %{"_target" => ["sections", location, "new"], "sections" => values},
        %{assigns: %{location_sections: location_sections}} = socket
      ) do
    section_id = values[location]["new"]
    location = String.to_existing_atom(location)

    location_sections =
      location_sections
      |> Enum.map(fn {key, label, sections} = loc ->
        if key == location do
          {key, label, sections ++ [section_id]}
        else
          loc
        end
      end)

    {:noreply,
     socket
     |> assign(location_sections: location_sections)}
  end

  def handle_event(
        "change_section",
        %{"_target" => ["sections", location, index], "sections" => values},
        %{assigns: %{location_sections: location_sections}} = socket
      ) do
    section_id = values[location][index]
    location = String.to_existing_atom(location)
    {index, _} = Integer.parse(index)

    location_sections =
      location_sections
      |> Enum.map(fn {key, label, sections} = loc ->
        if key == location do
          {key, label, List.replace_at(sections, index, section_id)}
        else
          loc
        end
      end)

    {:noreply,
     socket
     |> assign(location_sections: location_sections)}
  end

  def handle_event(
        "remove|" <> rest,
        _value,
        %{assigns: %{location_sections: location_sections}} = socket
      ) do
    [location, index] = String.split(rest, "|")
    {index, _} = Integer.parse(index)
    location = String.to_existing_atom(location)

    location_sections =
      location_sections
      |> Enum.map(fn {key, label, sections} = loc ->
        if key == location do
          {key, label, List.delete_at(sections, index)}
        else
          loc
        end
      end)

    {:noreply,
     socket
     |> assign(location_sections: location_sections)}
  end

  def handle_event(
        "save",
        _params,
        %{assigns: %{location_sections: location_sections, reflectos_layout: %Layout{} = layout}} =
          socket
      ) do
    sections =
      location_sections
      |> Enum.reduce(%{}, fn {key, _label, sections}, acc ->
        Map.put(acc, key, sections)
      end)

    layout = %{layout | sections: sections}

    case LayoutStore.save(layout) do
      {:ok, layout} ->
        notify_parent({:saved, layout})

        {:noreply,
         socket
         |> put_flash(:info, "Layout updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      error ->
        {:noreply,
         socket
         |> put_flash(:eror, "Error saving layout: #{error}")}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
