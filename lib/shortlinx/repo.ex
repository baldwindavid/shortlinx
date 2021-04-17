defmodule Shortlinx.Repo do
  use Ecto.Repo,
    otp_app: :shortlinx,
    adapter: Ecto.Adapters.Postgres
end
