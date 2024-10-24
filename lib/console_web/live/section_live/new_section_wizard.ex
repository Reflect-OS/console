defmodule ReflectOS.ConsoleWeb.SectionLive.NewSectionWizard do
  use ReflectOS.ConsoleWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        :if={@step == 1}
        id="new-section-wizard-step-1"
        wizard_id={@id}
        module={ReflectOS.ConsoleWeb.SectionLive.NewFormComponent}
      />

      <.live_component
        :if={@step == 2}
        id="new-section-wizard-step-2"
        module={ReflectOS.ConsoleWeb.SectionLive.ConfigFormComponent}
        section={@section}
        patch={@patch}
      />
    </div>
    """
  end

  @impl true
  def update(%{new_section: section} = assigns, socket) do
    section = %{section | config: struct(section.module, %{})}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(section: section)
     |> assign(step: 2)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(step: 1)}
  end
end
