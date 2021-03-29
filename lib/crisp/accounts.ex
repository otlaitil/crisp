defmodule Crisp.Accounts do
  import Ecto.Query
  alias Crisp.Repo
  alias Crisp.Accounts.{AuthorizationCodeRequest, Employee, PersonalIdentity}
  alias Crisp.IdentityServiceBroker

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
      {:ok, query} <- AuthorizationCodeRequest.get_by_state_query(state),
      %AuthorizationCodeRequest{} = request <- Repo.one(query),
      {:ok, identity} <- IdentityServiceBroker.get_identity(authorization_code, request.nonce),
      :ok <- AuthorizationCodeRequest.verify_nonce(request, identity.nonce),
      employee = get_employee_by_personal_identity_code(identity.personal_identity_code)
    ) do
      case {request.context, employee} do
        {:registration, nil} ->
          Repo.transaction(register_account_multi(identity, request))
          {:registered}

        {:registration, %Employee{}} ->
          {:login}

        {:login, %Employee{}} ->
          {:login}

        {:login, nil} ->
          {:error, "Employee not found"}

        {:reset_password, %Employee{}} ->
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

  def get_employee_by_personal_identity_code(personal_identity_code) do
    Repo.one(
      from e in Employee,
        join: p in PersonalIdentity,
        on: p.employee_id == e.id,
        where: p.code == ^personal_identity_code
    )
  end

  defp register_account_multi(identity, request) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:employee, %Employee{})
    |> Ecto.Multi.insert(:personal_identity, fn %{
                                                  employee: employee
                                                } ->
      code = identity.personal_identity_code
      Ecto.build_assoc(employee, :personal_identity, code: code)
    end)
    |> Ecto.Multi.delete_all(
      :tokens,
      from(r in AuthorizationCodeRequest, where: r.state == ^request.state)
    )
  end
end
