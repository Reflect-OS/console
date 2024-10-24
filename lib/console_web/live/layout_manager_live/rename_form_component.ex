defmodule ReflectOS.ConsoleWeb.LayoutManagerLive.RenameFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.LayoutManager.Changeset, as: LayoutManagerChangeset

  alias ReflectOS.Kernel.LayoutManager
  alias ReflectOS.Kernel.Settings.LayoutManagerStore

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="inline-flex items-center">
        <%= %{icon: icon} = @layout_manager.module.layout_manager_definition()

        raw_icon(icon, class: "w-6 h-6 self-center mr-3") %>
        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            Rename Layout Manager
          </h5>
          <p class="font-thin">
            <%= @layout_manager.name %>
          </p>
        </div>
      </div>

      <.simple_form
        id="layout_manager-rename-form"
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">Rename Layout Manager</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{layout_manager: %LayoutManager{} = layout_manager} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(LayoutManagerChangeset.change(layout_manager), as: "layout_manager")
     end)}
  end

  @impl true
  def handle_event("validate", %{"layout_manager" => layout_manager_params}, socket) do
    changeset =
      LayoutManagerChangeset.change(socket.assigns[:layout_manager], layout_manager_params)

    {:noreply, assign(socket, form: to_form(changeset, as: "layout_manager", action: :validate))}
  end

  def handle_event("save", %{"layout_manager" => layout_manager_params}, socket) do
    save_layout_manager(socket, layout_manager_params)
  end

  defp save_layout_manager(socket, layout_manager_params) do
    layout_manager = socket.assigns[:layout_manager]

    case LayoutManagerChangeset.change(layout_manager, layout_manager_params) do
      %Changeset{valid?: false} = changeset ->
        {:noreply, assign(socket, form: to_form(changeset, as: "layout_manager", action: :validate))}

      # If there are no changes, just go back
      %Changeset{changes: changes} when changes == %{} or changes == [] ->
        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      %Changeset{valid?: true} = changeset ->
        layout_manager = Changeset.apply_changes(changeset)

        LayoutManagerStore.save(layout_manager)
        notify_parent({:saved, layout_manager})

        {:noreply,
         socket
         |> put_flash(:info, "Layout Manager updated successfully")
         |> push_patch(to: socket.assigns.patch)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
