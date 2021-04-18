defmodule ShortlinxWeb.RedirectController do
  use ShortlinxWeb, :controller

  alias Shortlinx.LinkMgmt

  def show(conn, %{"shortcode" => shortcode}) do
    case LinkMgmt.get_link_by_shortcode(shortcode) do
      nil ->
        conn
        |> put_flash(:error, "Sorry, but that link does not exist")
        |> redirect(to: Routes.link_new_path(conn, :new))

      link ->
        LinkMgmt.record_visit(link)
        redirect(conn, external: link.url)
    end
  end
end
