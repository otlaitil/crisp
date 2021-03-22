defmodule Crisp.IdentityServiceBroker do
  @moduledoc """
  This module acts as an interface to the OP Identity Service Broker.
  """

  alias Crisp.IdentityServiceBroker.IdentityProvider

  def list_identity_providers() do
    [
      %IdentityProvider{
        id: "fi-op",
        name: "OP",
        image_url: "http://localhost:4000/images/phoenix.png"
      }
    ]
  end
end
