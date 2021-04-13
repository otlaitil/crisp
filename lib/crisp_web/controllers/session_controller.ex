defmodule CrispWeb.SessionController do
  use CrispWeb, :controller

  alias Crisp.Accounts
  alias CrispWeb.Authentication

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"employee" => %{"email" => email, "password" => %{"password" => password}}}) do
    if employee = Accounts.get_employee_by_email_and_password(email, password) do
      Authentication.log_in(conn, employee)
    else
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> Authentication.log_out()
  end
end
