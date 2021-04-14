defmodule CrispWeb.AccountRegistrationController do
  use CrispWeb, :controller

  import CrispWeb.Authentication
  alias Crisp.Accounts

  def new(conn, _params) do
    {:ok, identity_providers} = Accounts.list_identity_providers()
    render(conn, "new.html", identity_providers: identity_providers)
  end

  # TODO: Create nonce etc.
  def create(conn, %{"idp" => identity_provider} = params) do
    redirect_url = Accounts.initiate_identification(identity_provider, :registration)

    redirect(conn, external: redirect_url)
  end

  def show(conn, %{"state" => state, "code" => authorization_code} = params) do
    case Accounts.get_identity(state, authorization_code) do
      {:registered, employee} ->
        conn
        |> log_in(employee)
        |> redirect(to: Routes.email_confirmation_path(conn, :confirm))

      {:login, employee} ->
        conn
        |> log_in(employee)
        |> render("login.html")

      {:reset_password} ->
        render(conn, "reset_password.html")

      {:error, error_message} ->
        render(conn, "error.html", message: error_message)

      _ ->
        render(conn, "error.html", message: "General error")
    end
  end
end
