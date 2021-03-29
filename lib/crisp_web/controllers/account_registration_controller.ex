defmodule CrispWeb.AccountRegistrationController do
  use CrispWeb, :controller

  alias Crisp.Accounts

  def new(conn, _params) do
    identity_providers = Accounts.list_identity_providers()
    render(conn, "new.html", identity_providers: identity_providers)
  end

  # TODO: Create nonce etc.
  def create(conn, %{"idp" => identity_provider} = params) do
    # TODO: state and code wouldn't actually be in the request. They are
    # there to fake the redirect from ISB to SP. The redirect url would
    # actually be `_url` (not `_path`) and redirect should be to
    # `external` (instead of `to:`).
    redirect_url =
      Accounts.initiate_identification(
        identity_provider,
        :registration,
        &Routes.account_registration_path(conn, :show,
          state: &1,
          code: "authorization-code"
        )
      )

    redirect(conn, to: redirect_url)
  end

  def show(conn, %{"state" => state, "code" => authorization_code} = params) do
    case Accounts.get_identity(state, authorization_code) do
      {:registered} -> render(conn, "registered.html")
      {:login} -> render(conn, "login.html")
      {:reset_password} -> render(conn, "reset_password.html")
      {:error, error_message} -> render(conn, "error.html", message: error_message)
      _ -> render(conn, "error.html", message: "General error")
    end
  end
end
