defmodule ShortlinxWeb.LinkLiveTest do
  use ShortlinxWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shortlinx.LinkMgmt

  @valid_attrs %{shortcode: "ShrtCd", url: "http://example.com"}
  @update_attrs %{shortcode: "uPDaTe", url: "http://updated.com"}
  @invalid_attrs %{shortcode: "nope", url: "http://"}

  defp fixture(:link) do
    {:ok, link} = LinkMgmt.create_link(@valid_attrs)
    link
  end

  defp create_link(_) do
    link = fixture(:link)
    %{link: link}
  end

  describe "New" do
    test "saves a new link", %{conn: conn} do
      {:ok, view, _} = live(conn, Routes.link_new_path(conn, :new))

      {:ok, _, html} =
        view
        |> form("#link-form", link: @valid_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Link created successfully"
      assert html =~ "ShrtCd"
      assert html =~ "http://example.com"
    end

    test "displays errors with invalid link attributes", %{conn: conn} do
      {:ok, view, _} = live(conn, Routes.link_new_path(conn, :new))

      html =
        view
        |> form("#link-form", link: @invalid_attrs)
        |> render_change()

      assert html =~ "should be 6 character(s)"
      assert html =~ "must include a host"
    end
  end

  describe "Show" do
    setup [:create_link]

    test "displays a link", %{conn: conn, link: link} do
      {:ok, _, html} = live(conn, Routes.link_show_path(conn, :show, link))

      assert html =~ "Copy Your Shortlink"
      assert html =~ link.shortcode
      assert html =~ link.url
      assert html =~ "No visits yet"
    end

    test "clicking the Edit button redirects to the Edit page", %{conn: conn, link: link} do
      {:ok, view, _} = live(conn, Routes.link_show_path(conn, :show, link))

      view
      |> element("a", "Edit Link")
      |> render_click()

      assert_redirect(view, Routes.link_edit_path(conn, :edit, link))
    end

    test "updates the visit count in real-time when a visit occurs", %{
      conn: conn,
      link: link
    } do
      {:ok, view, html} = live(conn, Routes.link_show_path(conn, :show, link))

      assert html =~ "No visits yet"

      LinkMgmt.record_visit(link)
      LinkMgmt.record_visit(link)

      assert has_element?(view, "#visits", "Number of Visits: 2")
    end
  end

  describe "Edit" do
    setup [:create_link]

    test "updates a link", %{conn: conn, link: link} do
      {:ok, view, _} = live(conn, Routes.link_edit_path(conn, :edit, link))

      {:ok, _, html} =
        view
        |> form("#link-form", link: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Link updated successfully"
    end

    test "displays errors with invalid link attributes", %{conn: conn, link: link} do
      {:ok, view, _} = live(conn, Routes.link_edit_path(conn, :edit, link))

      html =
        view
        |> form("#link-form", link: @invalid_attrs)
        |> render_change()

      assert html =~ "should be 6 character(s)"
      assert html =~ "must include a host"
    end
  end
end
