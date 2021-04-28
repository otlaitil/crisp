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

  def validate(claims) do
    # iss: This should be the same as issuer key in .well-known/openid-configuration metadata
    # aud: It MUST contain the SP client_id
    # exp: Expiration time in seconds since UNIX epoch on or after which the ID Token MUST NOT be accepted for processing
    # nonce: must be the same we have
    claims
  end
end
