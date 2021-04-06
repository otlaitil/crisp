defmodule CrispWeb.EmailConfirmationController do
  use CrispWeb, :controller
  alias Crisp.Accounts

  # Do not log in the account after confirmation to avoid a
  # leaked token giving the account access to the account.
  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_account(token) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Account confirmed successfully.")
        |> redirect(to: "/")

      :error ->
        # If there is a current account and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the account themselves, so we redirect without
        # a warning message.
        case conn.assigns do
          %{current_account: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(conn, to: "/")

          %{} ->
            conn
            |> put_flash(:error, "Account confirmation link is invalid or it has expired.")
            |> redirect(to: "/")
        end
    end
  end
end
