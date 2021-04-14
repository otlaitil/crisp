defmodule CrispWeb.CredentialsController do
  use CrispWeb, :controller
  alias Crisp.Accounts

  def new(conn, _params) do
    changeset = Accounts.change_email_and_password()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"registration" => params}) do
    employee = conn.assigns.current_employee

    case Accounts.register_email_and_password(
           employee,
           params,
           &Routes.email_confirmation_url(conn, :confirm, &1)
         ) do
      {:ok, email} ->
        conn
        |> put_flash(:info, "Email sent to #{email.address}")
        |> render("ok.html")

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
