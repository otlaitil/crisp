defmodule CrispWeb.CredentialsController do
  use CrispWeb, :controller
  alias Crisp.Accounts
  alias Crisp.Accounts.Registration

  def new(conn, _params) do
    # TODO: This should come from Accounts module
    changeset = Registration.changeset(%Registration{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"registration" => params}) do
    employee = Crisp.Repo.get(Crisp.Accounts.Employee, 1)

    case(Accounts.register_email_and_password(employee, params)) do
      :ok -> render(conn, "ok.html")
      {:error, changeset} -> render(conn, "new.html", changeset: changeset)
    end
  end
end
