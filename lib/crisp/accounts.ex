defmodule Crisp.Accounts do
  import Ecto.Query
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
  def get_identity(state, authorization_code) do
    request =
      Crisp.Repo.one(
        from r in AuthorizationCodeRequest,
          where: r.expired_at <= ^NaiveDateTime.utc_now() and r.state == ^state
      )

    if request do
      identity = IdentityServiceBroker.get_identity(authorization_code, request.nonce)

      # TODO: secure_compare?
      if identity.nonce == request.nonce do
        # person = PersonalIdentity.get_by_code(identity.personal_identity_code)
        person = %{}

        case {request.context, person} do
          {:registration, nil} ->
            "Success: Register user"

          {:registration, _} ->
            "Success: login"

          _ ->
            "Should never happen"
        end
      else
        {:error, "Nonce mismatch"}
      end
    else
      {:error, "Auth code request not found"}
    end
  end
end
