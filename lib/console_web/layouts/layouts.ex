defmodule ReflectOS.ConsoleWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use ReflectOS.ConsoleWeb, :controller` and
  `use ReflectOS.ConsoleWeb, :live_view`.
  """
  use ReflectOS.ConsoleWeb, :html

  import ReflectOS.ConsoleWeb.LayoutComponents

  embed_templates "templates/*"
end
