defmodule Crisp.IdentityServiceBroker do
  @moduledoc """
  This module acts as an interface to the OP Identity Service Broker.
  """

  alias Crisp.IdentityServiceBroker.{IdentityProvider, Identity}

  @base_url "https://isb-test.op.fi"
  @client_id "saippuakauppias"

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
  def get_identity(authorization_code, nonce) do
    url = @base_url <> "/oauth/token"

    headers = [
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Accept", "application/json"}
    ]

    signer = Joken.Signer.create("RS256", %{"pem" => Crisp.Accounts.pem()})

    claims = %{
      "sub" => "saippuakauppias",
      "aud" => "https://isb-test.op.fi/oauth/token"
    }

    {:ok, token, _claims} = Crisp.IdentityServiceBroker.Token.generate_and_sign(claims, signer)

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
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end

    # TODO: This is here to fake that the nonce comes from the ISB
    hashed_nonce = :crypto.hash(:sha256, nonce)
    encoded_nonce = Base.url_encode64(hashed_nonce, padding: false)

    {:ok,
     %Identity{
       birthdate: ~D[1900-01-01],
       given_name: "Matti Matias",
       family_name: "von Möttönen",
       name: "von Möttönen Matti Matias",
       personal_identity_code: "010100-969P",
       nonce: encoded_nonce
     }}
  end
end
