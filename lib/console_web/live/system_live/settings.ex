defmodule ReflectOS.ConsoleWeb.SystemLive.Settings do
  use ReflectOS.ConsoleWeb, :live_view

  alias ReflectOS.Kernel.Settings.LayoutManagerStore
  alias ReflectOS.Kernel.Settings.System

  @impl true
  def mount(_params, _session, socket) do
    layout_manager_options =
      LayoutManagerStore.list()
      |> Enum.map(fn %{id: id, name: name} ->
        {name, id}
      end)

    timezone_options =
      NervesTimeZones.time_zones()
      |> Enum.sort(fn tz1, tz2 ->
        case {tz1, tz2} do
          {"US/" <> rest1, "US/" <> rest2} ->
            rest1 <= rest2

          {"US/" <> _, _} ->
            true

          {_, "US/" <> _} ->
            false

          _ ->
            tz1 <= tz2
        end
      end)

    socket =
      socket
      |> assign(:page_title, "System Settings")
      |> assign(:layout_manager_options, layout_manager_options)
      |> assign(:timezone_options, timezone_options)
      |> assign(
        :form,
        to_form(%{
          "time_format" => System.time_format(),
          "timezone" => System.timezone(),
          "viewport_size" =>
            System.viewport_size()
            |> Tuple.to_list()
            |> Enum.join("x"),
          "show_instructions" => System.show_instructions?(),
          "layout_manager" => System.layout_manager()
        })
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("time_format_changed", %{"time_format" => time_format}, socket) do
    System.time_format(time_format)

    {:noreply, socket}
  end

  def handle_event("timezone_changed", %{"timezone" => timezone}, socket) do
    System.timezone(timezone)

    {:noreply, socket}
  end

  def handle_event(
        "show_instructions_changed",
        %{"show_instructions" => show_instructions},
        socket
      ) do
    System.show_instructions?(show_instructions)

    {:noreply, socket}
  end

  def handle_event(
        "layout_manager_changed",
        %{"layout_manager" => layout_manager},
        socket
      ) do
    System.layout_manager(layout_manager)

    {:noreply, socket}
  end

  def handle_event(
        "viewport_size_changed",
        %{"viewport_size" => viewport_size},
        %{assigns: %{form: form}} = socket
      ) do
    errors =
      if Regex.match?(~r/\d{3,4}x\d{3,4}/, viewport_size) do
        [width, height] =
          viewport_size
          |> String.split("x")
          |> Enum.map(fn size ->
            Integer.parse(size)
            |> elem(0)
          end)

        System.viewport_size({width, height})

        form.errors
        |> Keyword.delete(:viewport_size)
      else
        form.errors
        |> Keyword.put(
          :viewport_size,
          {"Invalid scren size, please enter in width by height format (e.g. 1080x1920)", []}
        )
      end

    params =
      form.params
      |> Map.put("viewport_size", viewport_size)

    socket =
      socket
      |> assign(form: %{form | errors: errors, params: params})

    {:noreply, socket}
  end
end
