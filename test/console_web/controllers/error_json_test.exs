defmodule ReflectOS.ConsoleWeb.ErrorJSONTest do
  use ReflectOS.ConsoleWeb.ConnCase, async: true

  test "renders 404" do
    assert ReflectOS.ConsoleWeb.ErrorJSON.render("404.json", %{}) == %{
             errors: %{detail: "Not Found"}
           }
  end

  test "renders 500" do
    assert ReflectOS.ConsoleWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
