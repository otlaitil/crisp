defmodule Crisp.Accounts do
  import Ecto.Query
  alias Crisp.Repo

  alias Crisp.Employees.{
    Employee,
    Session
  }

  alias Crisp.Accounts.{
    AuthorizationCodeRequest,
    Email,
    Password,
    PersonalIdentity,
    Registration
  }

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

  def pem do
    """
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEAymeGHGpfRUdQe0VmPei3ARFBjlpVrK06RpUF3PJATGkNwBoX
    4j6LIJuacTnmLOiTlj84qy8ggLmoKZqai6JVsGQV+ThlCcRoujHCkNq8eebLBu0c
    raNd62m+fXDfqrZ5TG7fTg6Da4Miv1rC2/hF5Cs3IukAJwHnbNSOY0Lq93jgV4fA
    t5BbpTttWKU/wBL+Pkei3Yd1pPoS9MmzLk/J8ZdoX72H/NzrXgO1AfoIFptdFMrV
    13jMZu5Y0NbggqPle1EQa/ErdLhqIOMfpllslxLPkZ/xq3+3ptogIFVOpnJ7CSLu
    r+F+xUdl94+0kPu3jkGZFICRb9bkg1A1BHKiQwIDAQABAoIBACDG9QPjAfyhGNpt
    maoK5p/ooHoiDN/Cyb4mYeWu4VS+aniigR2lTTiBmlgdrTW2kDfzkwS9xAC0kBP0
    snRMXJ4NBzXtuQcE5ITKjByTH5SKGHTNryg7XXlDDZMY1U+67xe+mLD2Trf5a4Yb
    d5TRttfFW89udhTbDRQls81FR/G9Oj+82VYQTWOdRl38aTYox29A94JIN/CymXJ5
    fVbZZbgG3Kvcu+pPckdrzKsogF9JwxpfSCica54UjD3jTN0uB1ZOl10wGYltR19e
    W/IG5hI6mL1sCaOL/UueBdsHY6FxiYOiJziZNkWf2dqo9rIhcpBi/2tsy14qg6F6
    DQD3oYkCgYEA/ocOqtCoqNm0Hrnb97GmjvAKznRR/hScFMkK40zWkS46kq5cnqat
    zYVCaVrH+wo0fTQrvP4LFOzMmn+d/RwrEPhOuT6xthzBAvM/AlTf6Qx/h4bqzNOk
    q/R3AS5OBim4oU7wY7fjCDgqc2EEbYKJ6WhvG0LhFwziq2J8efkh728CgYEAy5NG
    VRofmc6sJBBa34yBkyxcjhdY9+Q/jFckJn4NN3l3A4GJP2y6knPagAu0grevNH3u
    hBJExvmb9WZjQFo4jvAKF2e7Ip5nvbXJ21x0IeUcXSXG8artMFKRyMhdbcI9XHYD
    rbWgLQJXBTKKkcg5S9kgewK0a6AOZlT2BQYjUG0CgYEAvwhW9dWOAM0E51rPweRQ
    AlAfjDy5nV2Sl/cceOUe1fBAff7n/RtUr0ApTDGajsxmAOK7QSna32WrWvoVdfdC
    S4ZSb66iavDB3Jj83Z8ePyfmP63/ZKQkn/rnprc+UFnX/RnmSrGlcHHXSqmyTQ8A
    u3JqkadskYRWTBOrIVDfK3kCgYBOeTwgbAyIbrm+wSs2h2Qfhnc7MtbR4AN7JtBB
    ok+X9dOh31o3v8L/13b/6wMvbH02X+EEukIW7XtoEorp8J1ixDcvpIXnp2ZYI+5n
    B/Gga0AOzBQvbnM2MG4QFuSk/b5HmRp76MqQ7xj6YOw3nBYyHcW+hWFlJ3LFkbSw
    ZRhR1QKBgQCeAp+MS+bsdgMA+q3hcHP3IjRYqVPTMxfZzsoEifN9BYg6x6Ewgbih
    Rv7izBQK1jtACNjY4mTwZ+FmtvctY7sVRnXehuS0yYe/d4RSdXxuX6GoQRmJOreP
    UHJJrQtqEwf4iEdCkLNIBN9tEOFfksDk7J1kY52D1gj9c1JYTskwKw==
    -----END RSA PRIVATE KEY-----
    """
  end

  epoch = {{1970, 1, 1}, {0, 0, 0}}
  @epoch :calendar.datetime_to_gregorian_seconds(epoch)

  def initiate_identification(idp, context) do
    # TODO: Validate identity_provider and context
    {state, nonce, request} = AuthorizationCodeRequest.build(idp, context)
    Crisp.Repo.insert(request)

    expired_at_timestamp =
      request.expired_at
      |> NaiveDateTime.to_erl()
      |> :calendar.datetime_to_gregorian_seconds()
      |> Kernel.-(@epoch)

    current_time = Crisp.IdentityServiceBroker.current_time()

    claims = %{
      "client_id" => "saippuakauppias",
      "redirect_uri" => "http://localhost:4000/callback",
      "response_type" => "code",
      "scope" => "openid personal_identity_code profile",
      "ui_locales" => "en",
      "state" => state,
      "ftn_idp_id" => idp,
      "exp" => expired_at_timestamp,
      "nonce" => nonce,
      "jti" => Crisp.IdentityServiceBroker.generate_jti(),
      "iss" => "saippuakauppias",
      "iat" => current_time,
      "nbf" => current_time
    }

    IO.inspect(claims, label: "Generated claims")

    jwk = JOSE.JWK.from_pem(pem)
    jws = JOSE.JWS.from_map(%{"alg" => "RS256", "typ" => "JWT"})
    result = JOSE.JWT.sign(jwk, jws, claims)
    {_, token} = JOSE.JWS.compact(result)

    "https://isb-test.op.fi/oauth/authorize"
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(%{"request" => token}))
    |> URI.to_string()
  end

  # TODO: Bad name? What is the responsibility of this module?
  # TODO: case condition is probably a bitch to test, it might be necessary to extract it to a function
  # TODO: Better error handling. If base64 decoding fails, `:error` is returned. Otherwise this might be fine?
  def get_identity(state, authorization_code) do
    with(
      {:ok, query} <- AuthorizationCodeRequest.get_by_state_query(state),
      %AuthorizationCodeRequest{} = request <- Repo.one(query),
      {:ok, identity} <- IdentityServiceBroker.get_identity(authorization_code),
      :ok <- AuthorizationCodeRequest.verify_nonce(request, identity.nonce),
      employee = get_employee_by_personal_identity_code(identity.personal_identity_code)
    ) do
      case {request.context, employee} do
        {:registration, nil} ->
          {:ok, %{employee: employee}} =
            Repo.transaction(register_account_multi(identity, request))

          {:registered, employee}

        {:registration, %Employee{}} ->
          {:login, employee}

        {:login, %Employee{}} ->
          {:login, employee}

        {:login, nil} ->
          {:error, "Employee not found"}

        {:reset_password, %Employee{}} ->
          {:reset_password}

        {:reset_password, nil} ->
          {:error, "Employee not found"}

        {request, employee} ->
          {:error, request, employee}
      end
    else
      nil ->
        {:error, "AuthorizationCodeRequest expired or not found"}

      error ->
        IO.inspect(error, label: "Accounts.get_identity")
        error
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
    |> Ecto.Multi.insert(:employee, %Employee{onboarding_state: :create_account})
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

  def change_email_and_password(attrs \\ %{}) do
    Registration.changeset(attrs)
  end

  def register_email_and_password(employee, attrs, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    changeset = Registration.changeset(attrs)

    with {:ok, registration} <- Ecto.Changeset.apply_action(changeset, :insert),
         multi <- Registration.multi(employee, registration, confirmation_url_fun),
         {:ok, %{email: email}} <- Repo.transaction(multi) do
      {:ok, email}
    else
      # apply_action
      {:error, changeset} ->
        {:error, changeset}

      # transaction
      {:error, operation, multi_changeset, _} ->
        {:error, Registration.map_errors(operation, multi_changeset, changeset)}
    end
  end

  @doc """
  Confirms a account by the given token and updates employee onboarding state.
  If the token matches, the account account is marked as confirmed
  and the token is deleted.
  """
  def confirm_email(token) do
    with(
      {:ok, query} <- Email.verify_email_query(token),
      %Email{} = email <- Repo.one(query),
      {:ok, email} <- Repo.update(Email.confirm_changeset(email)),
      employee_changeset <-
        Employee.onboarding_changeset(email.employee, %{onboarding_state: :business_information}),
      {:ok, _employee} <- Repo.update(employee_changeset)
    ) do
      {:ok, email}
    else
      _ -> :error
    end
  end

  def get_employee_by_session_token(token) do
    {:ok, query} = Session.verify_token_query(token)
    Repo.one(query)
  end

  @doc """
  Gets a account by email and password.
  ## Examples
      iex> get_account_by_email_and_password("foo@example.com", "correct_password")
      %Account{}
      iex> get_account_by_email_and_password("foo@example.com", "invalid_password")
      nil
  """
  def get_employee_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    email =
      Repo.get_by(Email, address: email)
      |> Repo.preload([:employee])

    if Password.valid_password?(email, password), do: email.employee
  end

  @doc """
  Generates a session token.
  """
  def generate_employee_session_token(account, security) do
    {token, account_token} = Session.build_token(account, security)
    Repo.insert!(account_token)
    token
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(from Session, where: [token: ^token])

    :ok
  end

  def change_employee_personal_information(employee, attrs \\ %{}) do
    Employee.changeset(employee, attrs)
  end

  def update_employee_personal_information(employee, attrs) do
    attrs = Map.put(attrs, "onboarding_state", :complete)

    Employee.changeset(employee, attrs)
    |> Repo.update()
  end

  def cancel_identification(state) do
    {:ok, query} = AuthorizationCodeRequest.get_by_state_query(state)
    Repo.delete_all(query)

    :ok
  end
end
