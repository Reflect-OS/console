defmodule ReflectOS.ConsoleWeb.LayoutManagerLive.NewLayoutManagerWizard do
  use ReflectOS.ConsoleWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        :if={@step == 1}
        id="new-layout_manager-wizard-step-1"
        wizard_id={@id}
        module={ReflectOS.ConsoleWeb.LayoutManagerLive.NewFormComponent}
      />

      <.live_component
        :if={@step == 2}
        id="new-layout_manager-wizard-step-2"
        module={ReflectOS.ConsoleWeb.LayoutManagerLive.ConfigFormComponent}
        layout_manager={@layout_manager}
        patch={@patch}
      />
    </div>
    """
  end

  @impl true
  def update(%{new_layout_manager: layout_manager} = assigns, socket) do
    layout_manager = %{layout_manager | config: struct(layout_manager.module, %{})}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(layout_manager: layout_manager)
     |> assign(step: 2)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(step: 1)}
  end
end
