defmodule ReflectOS.ConsoleWeb.LayoutLive.RenameFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.Layout.Changeset, as: LayoutChangeset

  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Settings.LayoutStore

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="inline-flex items-center">
        {%{icon: icon} = @reflectos_layout.module.layout_definition()

        raw_icon(icon, class: "w-6 h-6 self-center mr-3")}
        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            Rename Layout
          </h5>
          <p class="font-thin">
            {@reflectos_layout.name}
          </p>
        </div>
      </div>

      <.simple_form
        id="layout-rename-form"
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">Rename Layout</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{reflectos_layout: %Layout{} = layout} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(LayoutChangeset.change(layout), as: "layout")
     end)}
  end

  @impl true
  def handle_event("validate", %{"layout" => layout_params}, socket) do
    changeset = LayoutChangeset.change(socket.assigns[:reflectos_layout], layout_params)
    {:noreply, assign(socket, form: to_form(changeset, as: "layout", action: :validate))}
  end

  def handle_event("save", %{"layout" => layout_params}, socket) do
    save_layout(socket, layout_params)
  end

  defp save_layout(socket, layout_params) do
    layout = socket.assigns[:reflectos_layout]

    case LayoutChangeset.change(layout, layout_params) do
      # If there are no changes, just go back
      %Changeset{changes: changes} when changes == %{} or changes == [] ->
        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      %Changeset{valid?: true} = changeset ->
        layout = Changeset.apply_changes(changeset)

        LayoutStore.save(layout)
        notify_parent({:saved, layout})

        {:noreply,
         socket
         |> put_flash(:info, "Layout updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      %Changeset{valid?: false} = changeset ->
        {:noreply, assign(socket, form: to_form(changeset, as: "layout", action: :validate))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
