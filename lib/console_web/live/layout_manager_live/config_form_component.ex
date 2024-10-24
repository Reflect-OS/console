defmodule ReflectOS.ConsoleWeb.LayoutManagerLive.ConfigFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.LayoutManager
  alias ReflectOS.Kernel.Settings.LayoutManagerStore

  @impl true
  def render(%{layout_manager: %LayoutManager{module: module}} = assigns) do
    assigns = assign(assigns, :config_options, module.layout_manager_options())

    ~H"""
    <div>
      <div class="inline-flex items-center">
        <%= %{icon: icon} = @layout_manager.module.layout_manager_definition()

        raw_icon(icon, class: "w-6 h-6 self-center mr-3") %>
        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            Configure Layout Manager
          </h5>
          <p class="font-thin">
            <%= @layout_manager.name %>
          </p>
        </div>
      </div>

      <.config_form
        id="layout_manager-config-form"
        for={@form}
        config_options={@config_options}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <:actions>
          <.button phx-disable-with="Saving...">Save Layout Manager</.button>
        </:actions>
      </.config_form>
    </div>
    """
  end

  @impl true
  def update(%{layout_manager: %LayoutManager{module: module, config: config}} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(module.changeset(config), as: "layout_manager")
     end)}
  end

  @impl true
  def handle_event("validate", %{"layout_manager" => layout_manager_params}, socket) do
    %LayoutManager{module: module, config: config} = socket.assigns[:layout_manager]
    changeset = module.changeset(config, layout_manager_params)
    {:noreply, assign(socket, form: to_form(changeset, as: "layout_manager", action: :validate))}
  end

  def handle_event("save", %{"layout_manager" => layout_manager_params}, socket) do
    save_layout_manager(socket, layout_manager_params)
  end

  defp save_layout_manager(socket, layout_manager_params) do
    layout_manager = socket.assigns[:layout_manager]

    case layout_manager.module.changeset(layout_manager.config, layout_manager_params) do
      # If there are no changes, just go back
      %Changeset{changes: changes}
      when (changes == %{} or changes == []) and layout_manager.id != nil ->
        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      %Changeset{valid?: true} = changeset ->
        layout_manager = %{layout_manager | config: Changeset.apply_changes(changeset)}

        case LayoutManagerStore.save(layout_manager) do
          {:ok, layout_manager} ->
            notify_parent({:saved, layout_manager})

            {:noreply,
             socket
             |> put_flash(:info, "Layout Manager saved successfully")
             |> push_patch(to: socket.assigns.patch)}

          error ->
            {:noreply,
             socket
             |> put_flash(:eror, "Error saving Layout Manager: #{error}")}
        end

      %Changeset{valid?: false} = changeset ->
        {:noreply, assign(socket, form: to_form(changeset, as: "layout_manager"))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
