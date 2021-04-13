defmodule CrispWeb.Authentication do
  import Plug.Conn
  import Phoenix.Controller

  alias Crisp.Users
  alias CrispWeb.Router.Helpers, as: Routes

  @doc """
  Authenticates the employee by looking into the session token
  """
  def fetch_current_employee(conn, _opts) do
    employee_token = get_session(conn, :employee_token)
    employee = employee_token && Accounts.get_employee_by_session_token(employee_token)
    assign(conn, :current_employee, employee)
  end

  @doc """
  Used for routes that require the employee to not be authenticated.
  """
  def redirect_authenticated_employee(conn, _opts) do
    if conn.assigns[:current_employee] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  defp signed_in_path(_conn), do: "/"

  @doc """
  Used for routes that require the employee to be authenticated.
  If you want to enforce the employee email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_employee(conn, _opts) do
    if conn.assigns[:current_employee] do
      conn
    else
      conn
      |> put_flash(:error, "You must log in to access this page.")
      |> maybe_store_return_to()
      |> redirect(to: Routes.employee_session_path(conn, :new))
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :employee_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn
end
