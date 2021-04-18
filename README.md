# Shortlinx

To view the application locally:

  * Download the repo with `git clone git@github.com:baldwindavid/shortlinx.git`
  * `cd` into the shortlinx repository
  * `/config/dev.secret.exs.template` is a template for your local development
    database credentials. Update the username/password to your credentials and
    remove the `.template` extension. The file should be named `dev.secret.exs`.
    This secret configuration is imported at the bottom of `dev.exs`. 
  * Perform the same operation for `/config/test.secret.exs.template`.
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`
  * Tests can be run with `mix test`
  * Visit [`localhost:4000`](http://localhost:4000) from your browser.
