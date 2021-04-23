defmodule Crisp.ClaimGenerationTest do
  use ExUnit.Case, async: true
  alias Crisp.ClaimGeneration

  test "mimicing joken claims" do
    current_time = Joken.current_time()
    jwt_id = Joken.generate_jti()

    joken_mimic_claims = %{
      "exp" => current_time + 2 * 60 * 60,
      "aud" => "Joken",
      "iat" => current_time,
      "iss" => "saippuakauppias",
      "nbf" => current_time,
      "client_id" => "saippuakauppias",
      "jti" => jwt_id
    }

    %{
      "client_id" => "saippuakauppias",
      "redirect_uri" => "http://localhost:4000/tunnistautuminen",
      "response_type" => "code",
      "scope" => "openid personal_identity_code profile",
      "ui_locales" => "en",
      "state" => "test-state",
      "ftn_idp_id" => "op",
      "exp" => "1",
      "nonce" => "test-nonce",
      "jti" => jwt_id
    }

    token_config = Crisp.IdentityServiceBroker.Token.token_config()
    {:ok, claims} = Joken.generate_claims(token_config, %{"jti" => jwt_id})

    # Test that claims match
    assert(joken_mimic_claims == claims)

    pem = Crisp.Accounts.pem()
    signer = Joken.Signer.create("RS256", %{"pem" => pem})

    {:ok, joken_token} = Joken.Signer.sign(claims, signer)
    {:ok, my_token} = Joken.Signer.sign(joken_mimic_claims, signer)

    # Test signing with just JOSE
    assert(my_token == joken_token)

    jwk = JOSE.JWK.from_pem(pem)
    jws = JOSE.JWS.from_map(%{"alg" => "RS256", "typ" => "JWT"})

    result = JOSE.JWT.sign(jwk, jws, claims)
    {_, compacted_token} = JOSE.JWS.compact(result)

    assert(compacted_token == joken_token)
  end

  test "validate" do
  end
end
