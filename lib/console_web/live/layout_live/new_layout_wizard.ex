defmodule ReflectOS.ConsoleWeb.LayoutLive.NewLayoutWizard do
  use ReflectOS.ConsoleWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        :if={@step == 1}
        id="new-layout-wizard-step-1"
        wizard_id={@id}
        wizard_step={1}
        module={ReflectOS.ConsoleWeb.LayoutLive.NewFormComponent}
      />

      <.live_component
        :if={@step == 2}
        id="new-layout-wizard-step-2"
        module={ReflectOS.ConsoleWeb.LayoutLive.ConfigFormComponent}
        reflectos_layout={@reflectos_layout}
        wizard_id={@id}
        wizard_step={2}
        patch={@patch}
      />

      <.live_component
        :if={@step == 3}
        id="new-layout-wizard-step-3"
        module={ReflectOS.ConsoleWeb.LayoutLive.ManageFormComponent}
        reflectos_layout={@reflectos_layout}
        patch={@patch}
      />
    </div>
    """
  end

  @impl true
  def update(%{new_layout: layout, step: step} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(reflectos_layout: layout)
     |> assign(step: step + 1)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(step: 1)}
  end
end
