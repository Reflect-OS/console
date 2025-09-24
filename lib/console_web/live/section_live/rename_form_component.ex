defmodule ReflectOS.ConsoleWeb.SectionLive.RenameFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.Section.Changeset, as: SectionChangeset

  alias ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.Settings.SectionStore

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="inline-flex items-center">
        {%{icon: icon} = @section.module.section_definition()

        raw_icon(icon, class: "w-6 h-6 self-center mr-3")}
        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            Rename Section
          </h5>
          <p class="font-thin">
            {@section.name}
          </p>
        </div>
      </div>

      <.simple_form
        id="section-rename-form"
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">Rename Section</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{section: %Section{} = section} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
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

        SectionStore.save(section)
        notify_parent({:saved, section})

        {:noreply,
         socket
         |> put_flash(:info, "Section updated successfully")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
