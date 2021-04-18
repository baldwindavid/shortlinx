defmodule ShortlinxWeb.Router do
  use ShortlinxWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ShortlinxWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ShortlinxWeb do
    pipe_through :browser

    live "/", LinkLive.New, :new
    live "/links/:id/edit", LinkLive.Edit, :edit
    live "/links/:id", LinkLive.Show, :show

    get "/:shortcode", RedirectController, :show
  end
end
