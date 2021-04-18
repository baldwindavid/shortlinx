defmodule ShortlinxWeb.LinkLive.Show do
  use ShortlinxWeb, :live_view

  alias Shortlinx.LinkMgmt

  def render(assigns) do
    ~L"""
    <h1>Copy Your Shortlink</h1>

    <input id="shortlink" type="text" class="url-input" value="<%= Routes.redirect_url(@socket, :show, @link.shortcode) %>" readonly phx-hook="InputSelectOnClick">
    <p>
      Your shortlink redirects to <a href="<%= @link.url %>" target="_blank"><%= @link.url %></a>
    </p>

    <p>
      <span><%= live_redirect "Edit Link", to: Routes.link_edit_path(@socket, :edit, @link), class: "button" %></span>
    </p>

    <%= if @link.visits_count > 0 do %>
      <div id="visits">
        <h2>Number of Visits: <%= @link.visits_count %></h2>
        <h2>Most Recent Timestamp: <%= @link.last_visit_at %></h2>
      </div>
    <% else %>
      <p class="alert alert-warning">No visits yet. Visit your shortlink in another browser window to see the visit count update in real-time.</p>
    <% end %>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    link = LinkMgmt.get_link!(id)

    if connected?(socket), do: LinkMgmt.subscribe(link)

    {:ok,
     socket
     |> assign(:page_title, "Your Link")
     |> assign(:link, link)}
  end

  def handle_info({:link_visited, link}, socket) do
    link = LinkMgmt.get_link!(link.id)
    {:noreply, assign(socket, :link, link)}
  end
end
