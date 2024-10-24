defmodule ReflectOS.ConsoleWeb.PageControllerTest do
  use ReflectOS.ConsoleWeb.ConnCase

  test "GET /about", %{conn: conn} do
    conn = get(conn, ~p"/about")
    assert html_response(conn, 200) =~ "ReflectOS"
  end
end
