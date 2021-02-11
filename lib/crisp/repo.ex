defmodule Crisp.Repo do
  use Ecto.Repo,
    otp_app: :crisp,
    adapter: Ecto.Adapters.Postgres
end
