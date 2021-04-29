defmodule OPISB.GetIdentity do
  def claims(client_id, base_url) do
    audience =
      (base_url <> "/oauth/authorize")
      |> URI.parse()
      |> URI.to_string()

    %{
      "iss" => client_id,
      "sub" => client_id,
      "aud" => audience,
      "jti" => OPISB.Claim.generate_jti(),
      "exp" => OPISB.Claim.expiration_time()
    }
  end

  def sign(claims, signing_key) do
    jwk = JOSE.JWK.from_pem(signing_key)
    jws = JOSE.JWS.from_map(%{"alg" => "RS256", "typ" => "JWT"})
    result = JOSE.JWT.sign(jwk, jws, claims)
    {_, token} = JOSE.JWS.compact(result)
    token
  end

  def build_request(token, authorization_code, base_url) do
    url =
      (base_url <> "/oauth/token")
      |> URI.parse()
      |> URI.to_string()

    %HTTPoison.Request{
      method: :post,
      url: url,
      body:
        {:form,
         [
           {"code", authorization_code},
           {"grant_type", "authorization_code"},
           {"client_assertion_type", "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"},
           {"client_assertion", token}
         ]},
      headers: [
        Accept: "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      ]
    }
  end

  def decrypt(id_token, decrypt_key) do
    jwk = JOSE.JWK.from_pem(decrypt_key)
    {decrypted_token, _jwe} = JOSE.JWE.block_decrypt(jwk, id_token)
    decrypted_token
  end

  # TODO: Rename this function
  # TODO: Select the key in a sane way (not first in the list)
  def jwks() do
    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      HTTPoison.get("https://isb-test.op.fi/jwks/broker")

    Jason.decode!(body)
    |> Map.get("keys")
    |> List.first()
    |> JOSE.JWK.from()
  end

  def verify(jwk, decrypted_token) do
    {true, %JOSE.JWT{fields: claims}, _jws} =
      JOSE.JWT.verify_strict(jwk, ["RS256"], decrypted_token)

    claims
  end

  # iss: This should be the same as issuer key in .well-known/openid-configuration metadata
  # aud: It MUST contain the SP client_id
  # exp: Expiration time in seconds since UNIX epoch on or after which the ID Token MUST NOT be accepted for processing
  # nonce: must be the same we have
  def validate(claims, client_id, base_url, opts \\ []) do
    data = %{}

    types = %{
      acr: :string,
      aud: :string,
      auth_time: :integer,
      birthdate: :string,
      exp: :integer,
      iat: :integer,
      iss: :string,
      name: :string,
      nonce: :string,
      personal_identity_code: :string,
      sub: :string
    }

    nonce = Keyword.get(opts, :nonce)

    {data, types}
    |> Ecto.Changeset.cast(claims, Map.keys(types))
    |> Ecto.Changeset.validate_required([:iss, :aud, :exp])
    |> Ecto.Changeset.validate_inclusion(:iss, [base_url])
    |> Ecto.Changeset.validate_inclusion(:aud, [client_id])
    |> Ecto.Changeset.validate_number(:exp, greater_than: OPISB.Claim.current_time())
    |> validate_nonce(nonce, [])
    |> Ecto.Changeset.apply_action(:insert)
  end

  defp validate_nonce(changeset, nil, _opts), do: changeset

  defp validate_nonce(changeset, expected, _opts) do
    Ecto.Changeset.validate_change(changeset, :nonce, fn :nonce, actual ->
      case Base.url_decode64(actual, padding: false) do
        {:ok, decoded_nonce} ->
          hashed_nonce = :crypto.hash(:sha256, decoded_nonce)

          case Plug.Crypto.secure_compare(expected, hashed_nonce) do
            true -> []
            false -> [nonce: "mismatch"]
          end

        :error ->
          [nonce: "decoding_error"]
      end
    end)
  end
end
