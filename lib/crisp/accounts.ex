defmodule Crisp.Accounts do
  import Ecto.Query
  alias Crisp.Repo
  alias Crisp.Accounts.Employee
  alias Crisp.IdentityServiceBroker
  alias Crisp.Accounts.AuthorizationCodeRequest

  @doc """
  Lists identity providers.

  ## Examples
  iex> list_identity_providers()
      %[%IdentityServiceBroker.IdentityProvider{}, ...]

  """
  def list_identity_providers() do
    IdentityServiceBroker.list_identity_providers()
  end

  def initiate_identification(idp, context, redirect_url_fun)
      when is_function(redirect_url_fun, 1) do
    {state, _nonce, request} = AuthorizationCodeRequest.build(idp)
    Crisp.Repo.insert(request)

    redirect_url_fun.(state)
  end

  # TODO: Bad name? What is the responsibility of this module?
  # TODO: case condition is probably a bitch to test, it might be necessary to extract it to a function
  # TODO: Better error handling. If base64 decoding fails, `:error` is returned. Otherwise this might be fine?
  def get_identity(state, authorization_code) do
    with(
      {:ok, query} <- AuthorizationCodeRequest.verify_query(state),
      %AuthorizationCodeRequest{} = request <- Repo.one(query),
      {:ok, identity} <- IdentityServiceBroker.get_identity(authorization_code, request.nonce)
      # employee = get_by_personal_identity_code(identity.personal_identity_code)
    ) do
      # TODO: Delete me
      employee = nil

      case {request.context, employee} do
        {:registration, nil} ->
          {:registered}

        {:registration, _} ->
          {:login}

        {:login, _} ->
          {:login}

        {:login, nil} ->
          {:error, "Employee not found"}

        {:reset_password, _} ->
          {:reset_password}

        {:reset_password, nil} ->
          {:error, "Employee not found"}

        _ ->
          :error
      end
    else
      nil -> {:error, "AuthorizationCodeRequest expired or not found"}
      error -> error
    end
  end
end
