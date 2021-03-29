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

  def initiate_identification(idp, context) do
    {state, nonce, request} = AuthorizationCodeRequest.build(idp)
    Crisp.Repo.insert(request)

    claims = %{
      "redirect_uri" => "http://localhost:4000/tunnistautuminen",
      "response_type" => "code",
      "scope" => "openid personal_identity_code profile",
      "nonce" => nonce,
      "state" => state,
      "ftn_idp_id" => idp
    }

    signer = Joken.Signer.create("RS256", %{"pem" => pem()})

    {:ok, token, _claims} = Crisp.IdentityServiceBroker.Token.generate_and_sign(claims, signer)

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
