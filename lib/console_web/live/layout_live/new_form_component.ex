defmodule ReflectOS.ConsoleWeb.LayoutLive.NewFormComponent do
  use ReflectOS.ConsoleWeb, :live_component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.Layout.Changeset, as: LayoutChangeset

  alias ReflectOS.Kernel.Layout
  alias ReflectOS.Kernel.Layout.Registry

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
          fill="none"
          viewBox="0 0 24 24"
        >
          <path
            stroke="currentColor"
            stroke-width="2"
            d="M3 11h18m-9 0v8m-8 0h16a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1Z"
          />
        </svg>

        <div>
          <h5 class="text-base font-semibold text-gray-500 uppercase dark:text-gray-400">
            New Layout
          </h5>
        </div>
      </div>

      <.simple_form
        id="layout-new-form"
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          label="Layout Type"
          field={@form[:module]}
          type="select"
          options={@module_options}
          prompt="-- Select Component --"
        />

        <.input field={@form[:name]} label="Name" />

        <:actions>
          <.button phx-disable-with="Saving...">Configure Layout</.button>
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
        %{name: name} = module.layout_definition()
        {name, module}
      end)

    layout = %Layout{}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(module_options: module_options)
     |> assign(reflectos_layout: layout)
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

        Phoenix.LiveView.send_update(ReflectOS.ConsoleWeb.LayoutLive.NewLayoutWizard, %{
          id: socket.assigns[:wizard_id],
          new_layout: layout,
          step: socket.assigns[:wizard_step]
        })

        {:noreply,
         socket
         |> assign(reflectos_layout: layout)}

      %Changeset{valid?: false} = changeset ->
        {:noreply, assign(socket, form: to_form(changeset, as: "layout", action: :validate))}
    end
  end
end
