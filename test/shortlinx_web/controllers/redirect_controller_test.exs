defmodule ShortlinxWeb.RedirectControllerTest do
  use ShortlinxWeb.ConnCase

  alias Shortlinx.LinkMgmt

  describe "GET /:shortcode -> show/2" do
    test "redirects to the external URL for the given shortcode and bumps the visit count", %{
      conn: conn
    } do
      {:ok, link} = LinkMgmt.create_link(%{shortcode: "abc123", url: "http://example.com"})
      link = LinkMgmt.get_link!(link.id)
      assert link.visits_count == 0

      conn = get(conn, Routes.redirect_path(conn, :show, link.shortcode))

      link = LinkMgmt.get_link!(link.id)
      assert link.visits_count == 1
      assert redirected_to(conn) == "http://example.com"
    end

    test "with no matching shortcode, redirects to the new link page", %{conn: conn} do
      conn = get(conn, Routes.redirect_path(conn, :show, "NOPE"))

      assert redirected_to(conn) == Routes.link_new_path(conn, :new)
      assert get_flash(conn, :error) == "Sorry, but that link does not exist"
    end
  end
end
