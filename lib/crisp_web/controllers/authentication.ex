defmodule CrispWeb.Authentication do
  import Plug.Conn
  import Phoenix.Controller

  alias Crisp.Accounts
  alias CrispWeb.Router.Helpers, as: Routes

  @doc """
  Logs the employee in.

  It renews the session ID and clears the whole session to avoid fixation
  attacks. See the renew_session function to customize this behaviour.

  It also sets a `:live_socket_id` key in the session, so LiveView
  sessions are identified and automatically disconnected on log out. The
  line can be safely removed if you are not using LiveView.
  """
  def log_in(conn, employee) do
    token = Accounts.generate_employee_session_token(employee, :weak)
    employee_return_to = get_session(conn, :employee_return_to)

    conn
    |> renew_session()
    |> put_session(:employee_token, token)
    |> put_session(:live_socket_id, "employees_sessions:#{Base.url_encode64(token)}")
    |> redirect(to: employee_return_to || signed_in_path(conn))
  end

  # This function renews the session ID and erases the whole
  # session to avoid fixation attacks. If there is any data
  # in the session you may want to preserve after log in/log out,
  # you must explicitly fetch the session data before clearing
  # and then immediately set it after clearing, for example:
  #
  #     defp renew_session(conn) do
  #       preferred_locale = get_session(conn, :preferred_locale)
  #
  #       conn
  #       |> configure_session(renew: true)
  #       |> clear_session()
  #       |> put_session(:preferred_locale, preferred_locale)
  #     end
  #
  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

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

  defp signed_in_path(_conn), do: "/"
end
