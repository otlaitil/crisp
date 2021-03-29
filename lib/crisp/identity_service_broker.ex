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
  def get_identity(_authorization_code, nonce) do
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
