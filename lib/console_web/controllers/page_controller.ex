defmodule ReflectOS.ConsoleWeb.PageController do
  use ReflectOS.ConsoleWeb, :controller

  alias ReflectOS.Kernel.Section.Registry, as: SectionRegistry
  alias ReflectOS.Kernel.Layout.Registry, as: LayoutRegistry
  alias ReflectOS.Kernel.LayoutManager.Registry, as: LayoutManagerRegistry

  def about(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    section_types =
      SectionRegistry.list()
      |> Enum.map(fn module ->
        module.section_definition()
      end)

    layout_types =
      LayoutRegistry.list()
      |> Enum.map(fn module ->
        module.layout_definition()
      end)

    layout_manager_types =
      LayoutManagerRegistry.list()
      |> Enum.map(fn module ->
        module.layout_manager_definition()
      end)

    render(conn, :about,
      active_tab: :about,
      section_types: section_types,
      layout_types: layout_types,
      layout_manager_types: layout_manager_types
    )
  end
end
