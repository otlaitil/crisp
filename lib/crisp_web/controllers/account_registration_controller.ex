defmodule CrispWeb.AccountRegistrationController do
  use CrispWeb, :controller

  alias Crisp.Accounts

  def new(conn, _params) do
    identity_providers = Accounts.list_identity_providers()
    render(conn, "new.html", identity_providers: identity_providers)
  end

  # TODO: Create nonce etc.
  def create(conn, _params) do
    redirect(conn, to: "/redirecturi")
  end

  # TODO: Check nonce, create a bunch of models
  def show(conn, _params) do
    render(conn, "show.html")
  end
end
