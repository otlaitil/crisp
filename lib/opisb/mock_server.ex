defmodule OPISB.MockServer do
  @client_id Application.get_env(:opisb, :client_id)

  import Plug.Conn
  use Plug.Router

  plug :match
  plug :dispatch

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  def init(options), do: options

  def start_link(_opts), do: start()

  def start(ref \\ __MODULE__) do
    _tid = :ets.new(__MODULE__, [:set, :public, :named_table])
    Plug.Cowboy.http(__MODULE__, [], ref: ref, port: 4010)
  end

  def stop(ref \\ __MODULE__) do
    Plug.Cowboy.shutdown(ref)
  end

  # TODO: Returns 404 when client_id is not found
  get "/api/embedded-ui/#{@client_id}" do
    body =
      Jason.encode!(%{
        "disturbanceInfo" => %{
          "header" => "Häiriöilmoitus",
          "text" => "Tässä on häiriöilmoituksen tilavaraus toteutuksen helpottamiseksi"
        },
        "identityProviders" => [
          %{
            "ftn_idp_id" => "idp",
            "imageUrl" => "http://localhost:4010/static/idp.svg",
            "name" => "Test IdP"
          }
        ],
        "isbConsent" =>
          "Tunnistautumisen yhteydessä palveluntarjoajalle välitetään: henkilötunnus, nimi.",
        "isbProviderInfo" =>
          "OP Tunnistuksen välityspalvelun tarjoaa OP Ryhmän osuuspankit ja OP Yrityspankki Oyj.",
        "privacyNoticeLink" => "https://isb-test.op.fi/privacy-info",
        "privacyNoticeText" => "OP tietosuojaseloste"
      })

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end

  get "/oauth/authorize" do
    conn = fetch_query_params(conn)
    IO.inspect(conn, label: "MockServer authorize")

    # TODO: If request is not found, return 400/bad_request
    request = conn.query_params["request"]
    token = JOSE.JWT.peek_payload(request)

    # 1. Generate authorization_code
    authorization_code =
      :crypto.strong_rand_bytes(24)
      |> Base.url_encode64(padding: false)

    # 2. Generate identity token
    jwk = JOSE.JWK.from_pem_file("priv/opisb/sandbox-sp-encryption-key.pem")
    jwt = JOSE.JWT.from(%{"test" => true})

    identity_token =
      JOSE.JWT.encrypt(jwk, jwt)
      |> JOSE.JWE.compact()
      |> elem(1)

    # 3. Save authorization_code and identity_token to ets
    :ets.insert(__MODULE__, {authorization_code, identity_token})

    # 4. Redirect client to token.redirect_uri with authorization_code and state
    state = token.fields["state"]
    redirect_query = %{"authorization_code" => authorization_code, "state" => state}

    redirect_uri =
      URI.parse(token.fields["redirect_uri"])
      |> Map.put(:query, URI.encode_query(redirect_query))
      |> URI.to_string()

    conn
    |> put_resp_header("Location", redirect_uri)
    |> resp(302, "")
    |> send_resp()
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
