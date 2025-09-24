defmodule ReflectOS.ConsoleWeb.LayoutLive.ConfigFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Settings.LayoutStore

  @impl true
  def render(%{reflectos_layout: %Layout{module: module}} = assigns) do
    assigns = assign(assigns, :config_options, module.layout_options())

    ~H"""
    <div>
      <div class="inline-flex items-center">
        {%{icon: icon} = @reflectos_layout.module.layout_definition()

        raw_icon(icon, class: "w-6 h-6 self-center mr-3")}
        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            Configure Layout
          </h5>
          <p class="font-thin">
            {@reflectos_layout.name}
          </p>
        </div>
      </div>

      <.config_form
        id="layout-config-form"
        for={@form}
        config_options={@config_options}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <:actions>
          <.button phx-disable-with="Saving...">
            {if @wizard_id == nil, do: "Save Layout", else: "Manage Sections"}
          </.button>
        </:actions>
      </.config_form>
    </div>
    """
  end

  @impl true
  def update(
        %{reflectos_layout: %Layout{module: module, config: config} = layout} = assigns,
        socket
      ) do
    config =
      if config == nil or !is_struct(config) do
        struct(module, %{})
      else
        config
      end

    layout = %{layout | config: config}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:reflectos_layout, layout)
     |> assign_new(:wizard_id, fn -> nil end)
     |> assign_new(:form, fn ->
       to_form(module.changeset(config), as: "layout")
     end)}
  end

  @impl true
  def handle_event("validate", %{"layout" => layout_params}, socket) do
    %Layout{module: module, config: config} = socket.assigns[:reflectos_layout]
    changeset = module.changeset(config, layout_params)
    {:noreply, assign(socket, form: to_form(changeset, as: "layout", action: :validate))}
  end

  def handle_event("save", %{"layout" => layout_params}, socket) do
    save_layout(socket, layout_params)
  end

  defp save_layout(socket, layout_params) do
    layout = socket.assigns[:reflectos_layout]
    # if we have a wizard id, send a message to it instead of going back to the home screen
    wizard_id = Map.get(socket.assigns, :wizard_id)

    case layout.module.changeset(layout.config, layout_params) do
      # If there are no changes, just go back
      %Changeset{changes: changes} when (changes == %{} or changes == []) and layout.id != nil ->
        {:noreply,
         socket
         |> push_patch(to: socket.assigns.patch)}

      %Changeset{valid?: true} = changeset ->
        layout = %{layout | config: Changeset.apply_changes(changeset)}

        if wizard_id == nil do
          # Not in a wizard, save and return to the patch location
          case LayoutStore.save(layout) do
            {:ok, layout} ->
              notify_parent({:saved, layout})

              {:noreply,
               socket
               |> put_flash(:info, "Layout saved successfully")
               |> push_patch(to: socket.assigns.patch)}

            error ->
              {:noreply,
               socket
               |> put_flash(:eror, "Error saving layout: #{error}")}
          end
        else
          # We're in the wizard, so pass along the upated layout
          Phoenix.LiveView.send_update(ReflectOS.ConsoleWeb.LayoutLive.NewLayoutWizard, %{
            id: socket.assigns[:wizard_id],
            new_layout: layout,
            step: socket.assigns[:wizard_step]
          })

          {:noreply,
           socket
           |> assign(reflectos_layout: layout)}
        end

      %Changeset{valid?: false} = changeset ->
        {:noreply, assign(socket, form: to_form(changeset, as: "layout", action: :validate))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
