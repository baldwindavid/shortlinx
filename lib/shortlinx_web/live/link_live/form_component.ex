defmodule ShortlinxWeb.LinkLive.FormComponent do
  use ShortlinxWeb, :live_component

  alias Shortlinx.LinkMgmt
  alias ShortlinxWeb.Endpoint

  @impl true
  def render(assigns) do
    ~L"""
    <%= f = form_for @changeset, "#",
      id: "link-form",
      phx_target: @myself,
      phx_change: "validate",
      phx_submit: "save" %>

      <%= text_input f, :url, phx_debounce: "500", class: "url-input", placeholder: "http://example.com" %>
      <%= error_tag f, :url %>

      <div class="row">
        <div class="column column-50">
          <div class="shortened-link-description">Customizable short link at... <span class="base-url"><%= Endpoint.url() %>/</span></div>
        </div>
        <div class="column column-25">
          <%= text_input f, :shortcode, phx_debounce: "500" %>
        </div>
      </div>
      <%= error_tag f, :shortcode %>

      <%= submit "Save", phx_disable_with: "Saving..." %>
    </form>
    """
  end

  @impl true
  def update(%{link: link} = assigns, socket) do
    changeset = LinkMgmt.change_link(link)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"link" => link_params}, socket) do
    changeset =
      socket.assigns.link
      |> LinkMgmt.change_link(link_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"link" => link_params}, socket) do
    save_link(socket, socket.assigns.action, link_params)
  end

  defp save_link(socket, :edit, link_params) do
    case LinkMgmt.update_link(socket.assigns.link, link_params) do
      {:ok, link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Link updated successfully")
         |> push_redirect(to: Routes.link_show_path(socket, :show, link))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_link(socket, :new, link_params) do
    case LinkMgmt.create_link(link_params) do
      {:ok, link} ->
        {:noreply,
         socket
         |> put_flash(:info, "Link created successfully")
         |> push_redirect(to: Routes.link_show_path(socket, :show, link))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
