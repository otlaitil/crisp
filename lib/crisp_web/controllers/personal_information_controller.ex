defmodule CrispWeb.PersonalInformationController do
  use CrispWeb, :controller

  alias Crisp.Accounts

  def new(conn, _params) do
    employee = conn.assigns.current_employee
    changeset = Accounts.change_employee_personal_information(employee)
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"employee" => params}) do
    employee = conn.assigns.current_employee

    case Accounts.update_employee_personal_information(employee, params) do
      {:ok, _employee} -> render(conn, "ok.html")
      {:error, changeset} -> render(conn, "new.html", changeset: changeset)
    end
  end
end
