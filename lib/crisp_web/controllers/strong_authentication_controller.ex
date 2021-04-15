defmodule CrispWeb.StrongAuthenticationController do
  use CrispWeb, :controller

  import CrispWeb.Authentication
  alias Crisp.Accounts

  def login(conn, _params), do: new(conn, :login)
  def registration(conn, _params), do: new(conn, :registration)
  def reset_password(conn, _params), do: new(conn, :reset_password)

  def new(conn, context) do
    {:ok, identity_providers} = Accounts.list_identity_providers()
    render(conn, "new.html", context: context, identity_providers: identity_providers)
  end

  # TODO: Create nonce etc.
  def create(conn, %{"idp" => identity_provider, "context" => context} = params) do
    redirect_url = Accounts.initiate_identification(identity_provider, context)

    redirect(conn, external: redirect_url)
  end

  def callback(conn, %{"state" => state, "code" => authorization_code} = params) do
    case Accounts.get_identity(state, authorization_code) do
      {:registered, employee} ->
        # TODO: This url is wrong - this should be like a static view with instructions like "go to your email, check your shit"
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

      {:error, request, employee} ->
        IO.inspect(request, label: "StrongAuthenticationController, error handler, request")
        IO.inspect(employee, label: "StrongAuthenticationController, error handler, employee")
        render(conn, "error.html", message: "General error")
    end
  end
end
