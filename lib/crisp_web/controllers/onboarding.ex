defmodule CrispWeb.Onboarding do
  import Plug.Conn
  import Phoenix.Controller

  alias CrispWeb.Router.Helpers, as: Routes

  def check_onboarding_state(%{assigns: %{current_employee: nil}} = conn, _opts), do: conn

  def check_onboarding_state(%{assigns: %{current_employee: employee}} = conn, _opts) do
    case employee.onboarding_state do
      :create_account ->
        conn
        |> put_flash(:info, "Onboarding on vielä kesken.")
        |> maybe_redirect_to(Routes.credentials_path(conn, :new))

      :confirm_email ->
        conn
        |> put_flash(:info, "Onboarding on vielä kesken.")
        |> maybe_redirect_to(Routes.email_confirmation_path(conn, :show))

      :business_information ->
        conn
        |> put_flash(:info, "Onboarding on vielä kesken.")
        |> maybe_redirect_to(Routes.personal_information_path(conn, :new))

      :complete ->
        conn
    end
  end

  def check_onboarding_state(conn, _opts), do: conn

  defp maybe_redirect_to(conn, redirect_path) do
    if conn.request_path == redirect_path do
      conn
    else
      redirect(conn, to: redirect_path)
      |> halt()
    end
  end
end
