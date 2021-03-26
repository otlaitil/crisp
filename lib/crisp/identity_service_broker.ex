defmodule Crisp.IdentityServiceBroker do
  @moduledoc """
  This module acts as an interface to the OP Identity Service Broker.
  """

  alias Crisp.IdentityServiceBroker.{IdentityProvider, Identity}

  def list_identity_providers() do
    [
      %IdentityProvider{
        id: "fi-op",
        name: "OP",
        image_url: "http://localhost:4000/images/phoenix.png"
      }
    ]
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
