defmodule ReflectOS.ConsoleWeb.LayoutComponents do
  use ReflectOS.ConsoleWeb, :html

  def navbar(assigns) do
    ~H"""
    <nav class="fixed bg-white px-4 py-2.5 dark:bg-gray-800 left-0 right-0 top-0 z-40">
      <div class="flex flex-wrap justify-center items-center relative">
        <button
          phx-click={show_sidebar()}
          aria-controls="default-sidebar"
          type="button"
          class="absolute inline-flex items-center left-0 text-sm text-gray-500 rounded-lg hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-gray-200 dark:text-gray-400 dark:hover:bg-gray-700 dark:focus:ring-gray-600"
        >
          <span class="sr-only">Open sidebar</span>
          <svg
            class="w-6 h-6"
            aria-hidden="true"
            fill="currentColor"
            viewBox="0 0 20 20"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              clip-rule="evenodd"
              fill-rule="evenodd"
              d="M2 4.75A.75.75 0 012.75 4h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 4.75zm0 10.5a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5a.75.75 0 01-.75-.75zM2 10a.75.75 0 01.75-.75h14.5a.75.75 0 010 1.5H2.75A.75.75 0 012 10z"
            >
            </path>
          </svg>
        </button>
        <div class="flex text-2xl whitespace-nowrap dark:text-white">
          <span class="font-extralight">
            Reflect
          </span>
          <span class="font-semibold">
            OS
          </span>
        </div>
      </div>
    </nav>
    """
  end

  def sidebar(assigns) do
    ~H"""
    <div id="sidebar-backdrop" class="hidden bg-gray-900/50 dark:bg-gray-900/80 fixed inset-0 z-30">
    </div>
    <aside
      id="sidebar"
      class="fixed hidden top-0 left-0 z-30 w-64 h-screen -translate-x-full bg-white border-r border-gray-200 md:translate-x-0 dark:bg-gray-800 dark:border-gray-700"
      aria-label="Sidebar"
      phx-click-away={hide_sidebar()}
    >
      <hr class="h-px mt-[52px] bg-gray-200 border-0 dark:bg-gray-700" />
      <div class="overflow-y-auto py-5 px-3 h-full bg-white dark:bg-gray-800">
        <ul class="space-y-2 font-medium">
          <li>
            <.link
              phx-click={
                hide_sidebar()
                |> JS.patch(~p"/")
              }
              class={[
                "flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group",
                if(@active_tab == :dashboard, do: "bg-gray-100 dark:bg-gray-600", else: "")
              ]}
            >
              <svg
                class="w-5 h-5 text-gray-500 transition duration-75 dark:text-gray-400"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="currentColor"
                viewBox="0 0 22 21"
              >
                <path
                  fill-rule="evenodd"
                  d="M11.293 3.293a1 1 0 0 1 1.414 0l6 6 2 2a1 1 0 0 1-1.414 1.414L19 12.414V19a2 2 0 0 1-2 2h-3a1 1 0 0 1-1-1v-3h-2v3a1 1 0 0 1-1 1H7a2 2 0 0 1-2-2v-6.586l-.293.293a1 1 0 0 1-1.414-1.414l2-2 6-6Z"
                  clip-rule="evenodd"
                />
              </svg>

              <span class="ms-3">Dashboard</span>
            </.link>
            <.link
              phx-click={
                hide_sidebar()
                |> JS.patch(~p"/sections")
              }
              class={[
                "flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group",
                if(@active_tab == :sections, do: "bg-gray-100 dark:bg-gray-600", else: "")
              ]}
            >
              <svg
                class="w-5 h-5 text-gray-500 transition duration-75 dark:text-gray-400"
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                fill="currentColor"
                viewBox="0 0 24 24"
              >
                <path d="M5 3a2 2 0 0 0-2 2v2a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2H5Zm14 18a2 2 0 0 0 2-2v-2a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2a2 2 0 0 0 2 2h4ZM5 11a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h4a2 2 0 0 0 2-2v-6a2 2 0 0 0-2-2H5Zm14 2a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h4Z" />
              </svg>
              <span class="ms-3">Sections</span>
            </.link>
            <.link
              phx-click={
                hide_sidebar()
                |> JS.patch(~p"/layouts")
              }
              class={[
                "flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group",
                if(@active_tab == :layouts, do: "bg-gray-100 dark:bg-gray-600", else: "")
              ]}
            >
              <svg
                class="w-5 h-5 text-gray-500 dark:text-gray-400"
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
              <span class="ms-3">Layouts</span>
            </.link>

            <.link
              phx-click={
                hide_sidebar()
                |> JS.patch(~p"/layout-managers")
              }
              class={[
                "flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group",
                if(@active_tab == :layout_managers, do: "bg-gray-100 dark:bg-gray-600", else: "")
              ]}
            >
              <svg
                class="w-5 h-5 text-gray-500 dark:text-gray-400"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                fill="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  fill-rule="evenodd"
                  d="M8 5a1 1 0 0 1 1-1h11a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2h-1a1 1 0 1 1 0-2h1V6H9a1 1 0 0 1-1-1Z"
                  clip-rule="evenodd"
                />
                <path
                  fill-rule="evenodd"
                  d="M4 7a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h11a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2H4Zm0 11v-5.5h11V18H4Z"
                  clip-rule="evenodd"
                />
              </svg>
              <span class="ms-3">Layout Managers</span>
            </.link>
            <.link
              phx-click={
                hide_sidebar()
                |> JS.patch(~p"/system/settings")
              }
              class={[
                "flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group",
                if(@active_tab == :settings, do: "bg-gray-100 dark:bg-gray-600", else: "")
              ]}
            >
              <svg
                class="w-5 h-5 text-gray-500 transition duration-75 dark:text-gray-400"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="currentColor"
                viewBox="0 0 22 21"
              >
                <path
                  fill-rule="evenodd"
                  d="M9.586 2.586A2 2 0 0 1 11 2h2a2 2 0 0 1 2 2v.089l.473.196.063-.063a2.002 2.002 0 0 1 2.828 0l1.414 1.414a2 2 0 0 1 0 2.827l-.063.064.196.473H20a2 2 0 0 1 2 2v2a2 2 0 0 1-2 2h-.089l-.196.473.063.063a2.002 2.002 0 0 1 0 2.828l-1.414 1.414a2 2 0 0 1-2.828 0l-.063-.063-.473.196V20a2 2 0 0 1-2 2h-2a2 2 0 0 1-2-2v-.089l-.473-.196-.063.063a2.002 2.002 0 0 1-2.828 0l-1.414-1.414a2 2 0 0 1 0-2.827l.063-.064L4.089 15H4a2 2 0 0 1-2-2v-2a2 2 0 0 1 2-2h.09l.195-.473-.063-.063a2 2 0 0 1 0-2.828l1.414-1.414a2 2 0 0 1 2.827 0l.064.063L9 4.089V4a2 2 0 0 1 .586-1.414ZM8 12a4 4 0 1 1 8 0 4 4 0 0 1-8 0Z"
                  clip-rule="evenodd"
                />
              </svg>

              <span class="ms-3">Settings</span>
            </.link>
            <.link
              phx-click={
                hide_sidebar()
                |> JS.patch(~p"/about")
              }
              class={[
                "flex items-center p-2 text-gray-900 rounded-lg dark:text-white hover:bg-gray-100 dark:hover:bg-gray-700 group",
                if(@active_tab == :about, do: "bg-gray-100 dark:bg-gray-600", else: "")
              ]}
            >
              <svg
                class="w-5 h-5 text-gray-800 dark:text-white"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                width="24"
                height="24"
                fill="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  fill-rule="evenodd"
                  d="M2 12C2 6.477 6.477 2 12 2s10 4.477 10 10-4.477 10-10 10S2 17.523 2 12Zm9.408-5.5a1 1 0 1 0 0 2h.01a1 1 0 1 0 0-2h-.01ZM10 10a1 1 0 1 0 0 2h1v3h-1a1 1 0 1 0 0 2h4a1 1 0 1 0 0-2h-1v-4a1 1 0 0 0-1-1h-2Z"
                  clip-rule="evenodd"
                />
              </svg>

              <span class="ms-3">About</span>
            </.link>
          </li>
        </ul>
      </div>
    </aside>
    """
  end

  def show_sidebar(js \\ %JS{}) do
    js
    |> JS.show(
      to: "#sidebar",
      time: 150,
      transition:
        {"transition-all transform ease-out duration-150", "-translate-x-full", "transform-none"}
    )
    |> JS.show(
      to: "#sidebar-backdrop",
      time: 150,
      transition: {"transition-all transform ease-out duration-150", "opacity-0", "opacity-100"}
    )
    |> JS.toggle_class("overflow-hidden", to: "body")
  end

  def hide_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#sidebar-backdrop",
      time: 150,
      transition: {"transition-all transform ease-in duration-150", "opacity-100", "opacity-0"}
    )
    |> JS.hide(
      to: "#sidebar",
      time: 150,
      transition:
        {"transition-all transform ease-in duration-150", "transform-none", "-translate-x-full"}
    )
    |> JS.toggle_class("overflow-hidden", to: "body")
  end
end
