defmodule CrispWeb.StrongAuthenticationController do
  use CrispWeb, :controller

  import CrispWeb.Authentication
  alias Crisp.Accounts

  def login(conn, _params), do: new(conn, :login)
  def registration(conn, _params), do: new(conn, :registration)
  def reset_password(conn, _params), do: new(conn, :reset_password)

  def new(conn, context) do
    eui = OPISB.get_embedded_ui()
    render(conn, "new.html", context: context, embedded_ui: eui)
  end

  # TODO: Create nonce etc.
  def create(conn, %{"idp" => identity_provider, "context" => context} = _params) do
    redirect_url = Accounts.initiate_identification(identity_provider, context)

    redirect(conn, external: redirect_url)
  end

  def callback(conn, %{"state" => state, "code" => authorization_code} = _params) do
    case Accounts.get_identity(state, authorization_code) do
      {:registered, employee} ->
        conn
        |> put_session(:employee_return_to, Routes.credentials_path(conn, :new))
        |> log_in(employee)

      {:login, employee} ->
        conn
        |> log_in(employee)
        |> render("login.html")

      {:reset_password} ->
        render(conn, "reset_password.html")

      {:error, error_message} ->
        render(conn, "error.html", message: error_message)

      {:error, request, employee} ->
        IO.inspect(request, label: "StrongAuthenticationController, error handler, request")
        IO.inspect(employee, label: "StrongAuthenticationController, error handler, employee")
        render(conn, "error.html", message: "General error")
    end
  end

  def callback(conn, %{"state" => state, "error" => _error} = _params) do
    Accounts.cancel_identification(state)

    conn
    |> put_flash(:info, "Tunnistautuminen peruttu.")
    |> render("login.html")
  end
end
