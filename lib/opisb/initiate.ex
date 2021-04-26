defmodule OPISB.Initiate do
  def claims(idp, client_id, redirect_uri, opts \\ [])
      when is_binary(idp) and is_binary(client_id) and is_binary(redirect_uri) do
    state = Keyword.get(opts, :state)
    nonce = Keyword.get(opts, :nonce)
    locale = Keyword.get(opts, :locale)
    exp = Keyword.get(opts, :exp, OPISB.Claim.expiration_time())

    %{
      "client_id" => client_id,
      "redirect_uri" => redirect_uri,
      "response_type" => "code",
      "scope" => "openid personal_identity_code profile",
      "ui_locales" => locale,
      "state" => state,
      "ftn_idp_id" => idp,
      "exp" => exp,
      "nonce" => nonce,
      "jti" => OPISB.Claim.generate_jti(),
      "iss" => client_id,
      "iat" => OPISB.Claim.current_time(),
      "nbf" => OPISB.Claim.current_time()
    }
    |> Enum.filter(fn {_, v} -> v end)
    |> Enum.into(%{})
  end

  def sign(claims, signing_key) do
    jwk = JOSE.JWK.from_pem(signing_key)
    jws = JOSE.JWS.from_map(%{"alg" => "RS256", "typ" => "JWT"})
    result = JOSE.JWT.sign(jwk, jws, claims)
    {_, token} = JOSE.JWS.compact(result)
    token
  end

  def build_url(token, base_url) do
    (base_url <> "/oauth/authorize")
    |> URI.parse()
    |> Map.put(:query, URI.encode_query(%{"request" => token}))
    |> URI.to_string()
  end
end
