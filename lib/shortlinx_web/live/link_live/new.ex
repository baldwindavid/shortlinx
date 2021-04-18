defmodule ShortlinxWeb.LinkLive.New do
  use ShortlinxWeb, :live_view

  alias Shortlinx.LinkMgmt

  @impl true
  def render(assigns) do
    ~L"""
    <h1>Shorten your link</h1>

    <%= live_component @socket, ShortlinxWeb.LinkLive.FormComponent,
      id: :new,
      action: @live_action,
      link: @link %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    link = LinkMgmt.new_link()

    {:ok,
     socket
     |> assign(:page_title, "New Link")
     |> assign(:link, link)}
  end
end
