defmodule ReflectOS.ConsoleWeb.SectionLive.ConfigFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.Section
  alias ReflectOS.Kernel.Settings.SectionStore

  @impl true
  def render(%{section: %Section{module: module}} = assigns) do
    assigns = assign(assigns, :config_options, module.section_options())

    ~H"""
    <div>
      <div class="inline-flex items-center">
        <%= %{icon: icon} = @section.module.section_definition()

        raw_icon(icon, class: "w-6 h-6 self-center mr-3") %>
        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            Configure Section
          </h5>
          <p class="font-thin">
            <%= @section.name %>
          </p>
        </div>
      </div>

      <.config_form
        id="section-config-form"
        for={@form}
        config_options={@config_options}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <:actions>
          <.button phx-disable-with="Saving...">Save Section</.button>
        </:actions>
      </.config_form>
    </div>
    """
  end

  @impl true
  def update(%{section: %Section{module: module, config: config}} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(module.changeset(config), as: "section")
     end)}
  end

  @impl true
  def handle_event("validate", %{"section" => section_params}, socket) do
    %Section{module: module, config: config} = socket.assigns[:section]
    changeset = module.changeset(config, section_params)
    {:noreply, assign(socket, form: to_form(changeset, as: "section", action: :validate))}
  end

  def handle_event("save", %{"section" => section_params}, socket) do
    save_section(socket, section_params)
  end

  defp save_section(socket, section_params) do
    section = socket.assigns[:section]

    case section.module.changeset(section.config, section_params) do
      %Changeset{valid?: false} = changeset ->
        {:noreply, assign(socket, form: to_form(changeset, as: "section", action: :validate))}

      # If there are no changes, just go back
      %Changeset{changes: changes} when (changes == %{} or changes == []) and section.id != nil ->
        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      %Changeset{valid?: true} = changeset ->
        section = %{section | config: Changeset.apply_changes(changeset)}

        case SectionStore.save(section) do
          {:ok, section} ->
            notify_parent({:saved, section})

            {:noreply,
             socket
             |> put_flash(:info, "Section saved successfully")
             |> push_patch(to: socket.assigns.patch)}

          error ->
            {:noreply,
             socket
             |> put_flash(:eror, "Error saving section: #{error}")}
        end
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
