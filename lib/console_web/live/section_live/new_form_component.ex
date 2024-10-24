defmodule ReflectOS.ConsoleWeb.SectionLive.NewFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.Section.Changeset, as: SectionChangeset

  alias ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.Section.Registry

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="inline-flex items-center">
        <svg
          class="w-6 h-6 text-gray-800 dark:text-white self-center mr-3"
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          fill="currentColor"
          viewBox="0 0 24 24"
        >
          <path d="M5 3a2 2 0 0 0-2 2v2a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2H5Zm14 18a2 2 0 0 0 2-2v-2a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2a2 2 0 0 0 2 2h4ZM5 11a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2v-6a2 2 0 0 0-2-2H5Zm14 2a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h4Z" />
        </svg>

        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            New Section
          </h5>
        </div>
      </div>

      <.simple_form
        id="section-new-form"
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          label="Section Type"
          field={@form[:module]}
          type="select"
          options={@module_options}
          prompt="-- Select Component --"
        />

        <.input field={@form[:name]} label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">Configure Section</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    module_options =
      Registry.list()
      |> Enum.map(fn module ->
        %{name: name} = module.section_definition()
        {name, module}
      end)

    section = %Section{}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(module_options: module_options)
     |> assign(section: section)
     |> assign_new(:form, fn ->
       to_form(SectionChangeset.change(section), as: "section")
     end)}
  end

  @impl true
  def handle_event("validate", %{"section" => section_params}, socket) do
    changeset = SectionChangeset.change(socket.assigns[:section], section_params)
    {:noreply, assign(socket, form: to_form(changeset, as: "section", action: :validate))}
  end

  def handle_event("save", %{"section" => section_params}, socket) do
    save_section(socket, section_params)
  end

  defp save_section(socket, section_params) do
    section = socket.assigns[:section]

    case SectionChangeset.change(section, section_params) do
      %Changeset{valid?: false} = changeset ->
        {:noreply, assign(socket, form: to_form(changeset, as: "section", action: :validate))}

      # If there are no changes, just go back
      %Changeset{changes: changes} when changes == %{} or changes == [] ->
        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      %Changeset{valid?: true} = changeset ->
        section = Changeset.apply_changes(changeset)

        Phoenix.LiveView.send_update(ReflectOS.ConsoleWeb.SectionLive.NewSectionWizard, %{
          id: socket.assigns[:wizard_id],
          new_section: section
        })

        {:noreply,
         socket
         |> assign(section: section)}
    end
  end
end
