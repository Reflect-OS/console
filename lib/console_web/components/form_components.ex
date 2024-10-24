defmodule ReflectOS.ConsoleWeb.FormComponents do
  @moduledoc """
  Provides form UI components.
  """
  use Phoenix.Component

  alias Ecto.Changeset

  alias ReflectOS.Kernel.OptionGroup
  alias ReflectOS.Kernel.Option

  @doc """
  Renders an input with label and error messages.

  A `Phoenix.HTML.FormField` may be passed as argument,
  which is used to retrieve the input name, id, and values.
  Otherwise all attributes may be passed explicitly.

  ## Types

  This function accepts all HTML input types, considering that:

    * You may also set `type="select"` to render a `<select>` tag

    * `type="checkbox"` is used exclusively to render boolean values

    * For live file uploads, see `Phoenix.Component.live_file_input/1`

  See https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
  for more information. Unsupported types, such as hidden and radio,
  are best written directly in your templates.

  ## Examples

      <.input field={@form[:email]} type="email" />
      <.input name="my-input" errors={["oh no!"]} />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               range search select tel text textarea time url week)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"

  attr :hidden?, :boolean,
    default: false,
    doc: "Determines whether the fields should be displayed"

  slot :help_text, doc: "the slot for helper text under the input."
  slot :icon, doc: "the slot for showing an icon in an input"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <div class={["mb-5", @hidden? && "hidden"]}>
      <label class="flex items-center gap-4 text-sm leading-6 text-zinc-600">
        <input type="hidden" name={@name} value="false" disabled={@rest[:disabled]} />
        <input
          type="checkbox"
          id={@id}
          name={@name}
          value="true"
          checked={@checked}
          class="rounded border-zinc-300 text-zinc-900 focus:ring-0"
          {@rest}
        />
        <%= @label %>
      </label>
      <p :if={is_function(@help_text)} class="mt-2 text-sm text-gray-500 dark:text-gray-400">
        <%= Phoenix.LiveView.TagEngine.component(
          @help_text,
          [],
          {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
        ) %>
      </p>
      <p
        :if={!is_function(@help_text) && @help_text != []}
        class="mt-2 text-sm text-gray-500 dark:text-gray-400"
      >
        <%= render_slot(@help_text) %>
      </p>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "select"} = assigns) do
    ~H"""
    <div class={["mb-5", @hidden? && "hidden"]}>
      <.label for={@id}>
        <%= @label %>
      </.label>
      <select
        id={@id}
        name={@name}
        class="bg-gray-50 border border-gray-300 text-gray-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
        multiple={@multiple}
        {@rest}
      >
        <option :if={@prompt} value=""><%= @prompt %></option>
        <%= Phoenix.HTML.Form.options_for_select(@options, @value) %>
      </select>
      <p :if={is_function(@help_text)} class="mt-2 text-sm text-gray-500 dark:text-gray-400">
        <%= Phoenix.LiveView.TagEngine.component(
          @help_text,
          [],
          {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
        ) %>
      </p>
      <p
        :if={!is_function(@help_text) && @help_text != []}
        class="mt-2 text-sm text-gray-500 dark:text-gray-400"
      >
        <%= render_slot(@help_text) %>
      </p>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  def input(%{type: "textarea"} = assigns) do
    ~H"""
    <div class={["mb-5", @hidden? && "hidden"]}>
      <.label for={@id}><%= @label %></.label>
      <textarea
        id={@id}
        name={@name}
        class={[
          "mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 min-h-[6rem]",
          @errors == [] && "border-zinc-300 focus:border-zinc-400",
          @errors != [] && "border-rose-400 focus:border-rose-400"
        ]}
        {@rest}
      ><%= Phoenix.HTML.Form.normalize_value("textarea", @value) %></textarea>
      <p :if={is_function(@help_text)} class="mt-2 text-sm text-gray-500 dark:text-gray-400">
        <%= Phoenix.LiveView.TagEngine.component(
          @help_text,
          [],
          {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
        ) %>
      </p>
      <p
        :if={!is_function(@help_text) && @help_text != []}
        class="mt-2 text-sm text-gray-500 dark:text-gray-400"
      >
        <%= render_slot(@help_text) %>
      </p>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  # All other inputs text, datetime-local, url, password, etc. are handled here...
  def input(assigns) do
    ~H"""
    <div class={["mb-5", @hidden? && "hidden"]}>
      <.label for={@id}><%= @label %></.label>
      <div class="relative">
        <div
          if={@icon != []}
          class="absolute inset-y-0 start-0 flex items-center ps-3.5 pointer-events-none"
        >
          <%= render_slot(@icon) %>
        </div>
        <input
          type={@type}
          name={@name}
          id={@id}
          value={Phoenix.HTML.Form.normalize_value(@type, @value)}
          class={[
            "bg-gray-50 border text-sm text-gray-900 rounded-lg  block w-full p-2.5 dark:bg-gray-700  dark:placeholder-gray-400 dark:text-white",
            @icon != [] && "ps-10",
            @errors == [] &&
              "border-gray-300 focus:ring-blue-500 focus:border-blue-500 dark:border-gray-600 dark:focus:ring-blue-500 dark:focus:border-blue-500",
            @errors != [] &&
              "border-red-500 focus:ring-red-500 focus:border-red-500 dark:border-red-500"
          ]}
          {@rest}
        />
      </div>

      <p :if={is_function(@help_text)} class="mt-2 text-sm text-gray-500 dark:text-gray-400">
        <%= Phoenix.LiveView.TagEngine.component(
          @help_text,
          [],
          {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
        ) %>
      </p>
      <p
        :if={!is_function(@help_text) && @help_text != []}
        class="mt-2 text-sm text-gray-500 dark:text-gray-400"
      >
        <%= render_slot(@help_text) %>
      </p>
      <.error :for={msg <- @errors}><%= msg %></.error>
    </div>
    """
  end

  @doc """
  Renders a label.
  """
  attr :for, :string, default: nil
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label for={@for} class="block mb-2 text-sm font-medium text-gray-900 dark:text-white">
      <%= render_slot(@inner_block) %>
    </label>
    """
  end

  @doc """
  Generates a generic error message.
  """
  slot :inner_block, required: true

  def error(assigns) do
    ~H"""
    <p class="mt-2 text-sm text-red-600 dark:text-red-500">
      <%= render_slot(@inner_block) %>
    </p>
    """
  end

  @doc """
  Renders a simple form.

  ## Examples

      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} label="Email"/>
        <.input field={@form[:username]} label="Username" />
        <:actions>
          <.button>Save</.button>
        </:actions>
      </.simple_form>
  """
  attr :for, :any, required: true, doc: "the data structure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div class="mt-5 space-y-8 bg-white">
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end

  # Renders an input for a given `ReflectOS.Kernel.Option`.
  attr :option, Option, doc: "Provided configuration for the input"
  attr :form, Phoenix.HTML.Form

  defp config_form_part(%{option: %OptionGroup{}} = assigns) do
    ~H"""
    <div>
      <h5 class="text-l font-medium text-gray-900 dark:text-white">
        <%= @option.label %>
      </h5>
      <hr class="h-px mb-3 bg-gray-200 border-0 dark:bg-gray-700" />
      <p :if={is_function(@option.description)} class="mb-3 text-sm text-gray-500 dark:text-gray-400">
        <%= Phoenix.LiveView.TagEngine.component(
          @option.description,
          [],
          {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
        ) %>
      </p>

      <.config_form_part :for={option <- @option.options} form={@form} option={option} />
    </div>
    """
  end

  defp config_form_part(
         %{form: form, option: %Option{key: key, label: label, hidden: hidden, config: config}} =
           assigns
       ) do
    data = Changeset.apply_changes(form.source)

    assigns
    |> assign(form: nil, option: nil)
    |> assign(field: form[key], label: label)
    |> assign(config)
    |> assign(hidden?: hidden != nil && hidden.(data))
    |> input()
  end

  @doc """
  Config Form
  """

  attr :for, :any, required: true, doc: "the data structure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :actions, doc: "the slot for form actions, such as a submit button"
  attr :config_options, :list, doc: "The list of optoins for this configuration"

  def config_form(assigns) do
    ~H"""
    <.simple_form :let={f} for={@for} as={@as} {@rest}>
      <.config_form_part :for={option <- @config_options} form={@for} option={option} />

      <div :for={action <- @actions} class="mt-2 flex items-center justify-between gap-6">
        <%= render_slot(action, f) %>
      </div>
    </.simple_form>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(ReflectOS.ConsoleWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ReflectOS.ConsoleWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
