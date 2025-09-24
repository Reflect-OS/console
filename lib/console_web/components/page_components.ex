defmodule ReflectOS.ConsoleWeb.PageComponents do
  @moduledoc """
  Provides core page components.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  import ReflectOS.ConsoleWeb.CoreComponents

  @doc """
  Renders a header with title.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true
  slot :actions
  slot :subtitle

  def header(assigns) do
    ~H"""
    <header>
      <h2 class={[
        "text-2xl font-semibold leading-none tracking-tight text-gray-900 md:text-4xl dark:text-white",
        @subtitle == [] && "mb-4"
      ]}>
        {render_slot(@inner_block)}
      </h2>
      <h3 :if={@subtitle != []} class="mb-4 font-thin">
        {render_slot(@subtitle)}
      </h3>
    </header>
    """
  end

  @doc """
  Renders a list of items
  """

  attr :id, :any
  attr :items, :list, required: true
  attr :item_id, :any, default: nil, doc: "the function for generating the item id"
  attr :item_click, :any, default: nil, doc: "the function for handling phx-click on each item"

  attr :item_map, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each item before"

  slot :item, required: true, doc: "Slot for rendering the content of a list item"

  def list(assigns) do
    assigns =
      with %{items: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, item_id: assigns.item_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div class="flow-root">
      <ul
        id={@id}
        phx-update={match?(%Phoenix.LiveView.LiveStream{}, @items) && "stream"}
        role="list"
        class="divide-y divide-gray-200 dark:divide-gray-700"
      >
        <li
          :for={item <- @items}
          id={@item_id && @item_id.(item)}
          class={["py-3 sm:py-4", @item_click && "hover:bg-gray-100 cursor-pointer"]}
          phx-click={@item_click && @item_click.(item)}
        >
          <div class="flex items-center relative">
            {render_slot(@item, @item_map.(item))}
          </div>
        </li>
      </ul>
    </div>
    """
  end

  attr :icon, :string, doc: "The raw SVG string to be used as an icon."

  attr :title_click, :any,
    default: nil,
    doc: "the function for handling phx-click on the title of the item"

  attr :title_icon, :string, default: nil, doc: "the hericon to append to the title"

  attr :id, :any, doc: "The unique id for this item"
  attr :title, :string
  attr :subtitle, :string
  attr :actions, :list, default: [], doc: "List of actions to show in the dropdown menu"

  def list_item(assigns) do
    ~H"""
    <div class="flex-shrink-0">
      <.icon raw={@icon} class="w-8 h-8" />
    </div>
    <div class="flex-1 min-w-0 ml-4">
      <p
        phx-click={@title_click && @title_click.(@id)}
        class="flex text-sm font-medium text-gray-900 truncate dark:text-white"
      >
        {@title}
        <.icon :if={@title_icon != nil} name={@title_icon} class="w-3 h-3 self-center ml-1" />
      </p>
      <p class="text-sm text-gray-500 truncate dark:text-gray-400">
        {@subtitle}
      </p>
    </div>
    <div class="flex-shrink-0">
      <button
        id={"action-menu-toggle-#{@id}"}
        phx-click={toggle_dropdown("#action-menu-#{@id}")}
        class="inline-flex items-center p-2 text-sm font-medium text-center text-gray-900 bg-white rounded-lg hover:bg-gray-100 focus:ring-4 focus:outline-none dark:text-white focus:ring-gray-50 dark:bg-gray-800 dark:hover:bg-gray-700 dark:focus:ring-gray-600"
        type="button"
      >
        <svg
          class="w-5 h-5"
          aria-hidden="true"
          xmlns="http://www.w3.org/2000/svg"
          fill="currentColor"
          viewBox="0 0 4 15"
        >
          <path d="M3.5 1.5a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Zm0 6.041a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Zm0 5.959a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0Z" />
        </svg>
      </button>
      <!-- Dropdown menu -->
      <div
        id={"action-menu-#{@id}"}
        phx-click-away={toggle_dropdown("#action-menu-#{@id}")}
        style="display: none"
        class="absolute right-0 z-10 bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700 dark:divide-gray-600"
      >
        <ul class="py-2 text-sm text-gray-700 dark:text-gray-200">
          <li :for={{label, patch, classes} <- @actions}>
            <a
              phx-click={JS.patch(patch) |> toggle_dropdown("action-menu-#{@id}")}
              class={"#{classes} block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white cursor-pointer"}
            >
              {label}
            </a>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  def toggle_dropdown(js \\ %JS{}, selector) do
    JS.toggle(js,
      to: selector,
      time: 100,
      in:
        {"transition-all transform ease-out duration-100",
         "opacity-0 -translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"},
      out:
        {"transition-all transform ease-in duration-100",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 -translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end
end
