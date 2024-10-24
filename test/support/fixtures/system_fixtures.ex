defmodule ReflectOS.Console.SystemFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ReflectOS.Console.System` context.
  """

  @doc """
  Generate a setting.
  """
  def setting_fixture(attrs \\ %{}) do
    {:ok, setting} =
      attrs
      |> Enum.into(%{})
      |> ReflectOS.Console.System.create_setting()

    setting
  end
end
