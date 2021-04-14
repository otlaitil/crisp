defmodule Crisp.IdentityServiceBroker do
  @moduledoc """
  This module acts as an interface to the OP Identity Service Broker.
  """

  alias Crisp.IdentityServiceBroker.{IdentityProvider, Identity}

  @base_url "https://isb-test.op.fi"
  @client_id "saippuakauppias"
  @expiration_time 10 * 60

  # TODO: Map response to IdentityProviders
  def list_identity_providers() do
    url = @base_url <> "/api/embedded-ui/" <> @client_id

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end
  end

  # TODO: Compare nonce
  def get_identity(authorization_code) do
    url = @base_url <> "/oauth/token"

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Accept", "application/json"}
    ]

    claims = %{
      "iss" => @client_id,
      "sub" => @client_id,
      "aud" => "https://isb-test.op.fi/oauth/token",
      "jti" => generate_jti(),
      "exp" => current_time() + @expiration_time
    }

    IO.inspect(claims, label: "Generated claims")

    jwk = JOSE.JWK.from_pem(Crisp.Accounts.pem())
    jws = JOSE.JWS.from_map(%{"alg" => "RS256", "typ" => "JWT"})
    result = JOSE.JWT.sign(jwk, jws, claims)
    {_, token} = JOSE.JWS.compact(result)

    body =
      {:form,
       [
         {"code", authorization_code},
         {"grant_type", "authorization_code"},
         {"client_assertion_type", "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"},
         {"client_assertion", token}
       ]}

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        decoded_body = Jason.decode!(body)
        id_token = decoded_body["id_token"]

        jwk = JOSE.JWK.from_pem(decrypt_pem())
        {decrypted_token, _jwe} = JOSE.JWE.block_decrypt(jwk, id_token)

        # JWKS
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
          HTTPoison.get("https://isb-test.op.fi/jwks/broker")

        # TODO: Select the key in a sane way! We currently just take the first!
        jwk_from_jwks =
          Jason.decode!(body)
          |> Map.get("keys")
          |> List.last()
          |> JOSE.JWK.from()

        # Verify
        {true, %JOSE.JWT{fields: claims}, _jws} =
          JOSE.JWT.verify_strict(jwk_from_jwks, ["RS256"], decrypted_token)

        IO.inspect(claims, label: "Identity token claims")

        # TODO: Validation
        # iss: This should be the same as issuer key in .well-known/openid-configuration metadata
        # aud: It MUST contain the SP client_id
        # exp: Expiration time in seconds since UNIX epoch on or after which the ID Token MUST NOT be accepted for processing
        # nonce: must be the same we have

        {:ok,
         %Identity{
           birthdate: claims["birthdate"],
           given_name: claims["given_name"],
           family_name: claims["family_name"],
           name: claims["name"],
           personal_identity_code: claims["personal_identity_code"],
           nonce: claims["nonce"]
         }}

      _ ->
        :error
    end
  end

  def decrypt_pem() do
    """
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEAxRXWHYRvsFJ6WGSiLSDZ5KgRHglSpTFbZsrZ/P6Sa9ZKeStO
    hcP0M4FO9ORdc12MsTPlFMIQy+6TiJXvZ8pxwcweFzaeGVBWtI/72waAHu5SSFnD
    pJ9SVRYCdCU95ONZAzNMaNNHTPivg5KgYL40yXZqGSCIApAEp7RcE6hm6PYdXLeW
    f/ATKNfVh9WMpMg49B5HWI7JPVjN8xVi73wjMKgKcReuX8T17HuF7wS0LZwWr80R
    8sXCevMKdUhah6YcF654eDsqYCEVrVAVOpdSMsmwkuoN0mnDmu8ltyCi+/46ibfm
    gDWFv/FIx+qAx92ADtBFYyhAiWEia4a67J7h6QIDAQABAoIBAEJd4RVdhJLWo1Zi
    xO33cwh5xBHeR9NS9Jl/07pLK5letwNonu+SlghGEgWLZSC1Lux5Mjo0Q524wDut
    acoEtRvylWtxu/mAQUJafhA6dyhzTogImkY0VHBMkhT0eYw7Nr1KJ//grdDwqYHf
    /Vu2kWYKFx5RAxwBzV9/78W63rSxnLkJJ37bD49zoGPPD/p07NyldeYOgB4D+tOj
    x9cPQYuJyyIicai+U1g32vQoW42LW7WZ8L+9DSX8Za2Y9EeIzzDbnSwSFHC5dbmf
    LLU2OATVOOC8+CKff5lLUZpU7Huta0MO/vsMbVk4BbX2tRaQjIO5QaZookaEw2nr
    ft7NgAECgYEA6cu3fgU7qGQ00foUXQ81MQqJnZzQfRybH8mk5K3AxyaPt0xm3bct
    tr42j5dvSgOeLUltIhyKK7ynu0eewOiOj1EQSr9MUCTX82u/GC5HIoajlpqNOjML
    3At2tNWp59kK8Xavh/7tziyaxC6jfGs90i1JMLyvw2qqfgD80+G30AECgYEA182T
    sAhwQDCzNZRTmnLqKpEIyLvvmGRMUMZbYCsTdFIRqJnp1NUWqPRlDrOyC/wjXXhE
    F8SIlEihFV03EDPQd+lN2S91bfWp6zmQQ/RNV2/EpEnveZ98sDUtWv7gD5y6Y2Og
    WgbiTjGdi6PdBAujCtQV/+zMTWJgLUDTgb+CkekCgYEAq3dmJv2tiE2d05Ym0y1x
    JHuG/FpjKi8Nsh2QWsr4BNdKNfPJybgrxcfxehRlYZIPs0UTzh3CVFtzZM4dJ3wn
    +gJJAZkVXf33h6axKwndz/uRBMZq55FClGqv7+Z4SvsKpJcYG5SjUj+ybkmKS5jX
    aUsfT6hC+/5B9lHBG6CC0AECgYBSWce/CClVxX/NtXGF4c5MOhZhC56tx7B7roYW
    F7oPzHWiokFiD4LbLJAX4SjTe/8+3vMVItF/zItz7KNjknI+IBCuDXdBY9rYwZm0
    5NhSwnsGupQhFGRvlYteSx7TtlpGLTF2yWO4tSRKslhX/9zS+AYBKKr56M2M100f
    GSbJaQKBgQC6G4U9Voj1JEdBn4DVCi8AvIxOBt6aXCzdXSwCRzrqJxDvVrk/36Ih
    WZJAdYnb6gmG04R0HMxfhuiYfscC+Fa9/9lhoS930cKLYtzEwf1ngS42+oS52imm
    /6a/W8zWAlpCfNJBBpwdloX7jfGNKmjwo82gFEbvwP4B5WujraxwMA==
    -----END RSA PRIVATE KEY-----
    """
  end

  def current_time(), do: DateTime.utc_now() |> DateTime.to_unix()

  @doc """
  Default function for generating `jti` claims. This was inspired by the `Plug.RequestId` generation.
  It avoids using `strong_rand_bytes` as it is known to have some contention when running with many
  schedulers.
  """
  def generate_jti() do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    Base.hex_encode32(binary, case: :lower)
  end
end
