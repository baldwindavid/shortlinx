defmodule ShortlinxWeb.LinkLive.Edit do
  use ShortlinxWeb, :live_view

  alias Shortlinx.LinkMgmt

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Edit Link</h1>

    <%= live_component @socket, ShortlinxWeb.LinkLive.FormComponent,
      id: @link.id,
      action: @live_action,
      link: @link %>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    link = LinkMgmt.get_link!(id)

    {:ok,
     socket
     |> assign(:page_title, "Edit Link")
     |> assign(:link, link)}
  end
end
