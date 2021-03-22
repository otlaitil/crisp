defmodule Crisp.Accounts do
  alias Crisp.Accounts.Employee
  alias Crisp.IdentityServiceBroker

  @doc """
  Lists identity providers.

  ## Examples
  iex> list_identity_providers()
      %[%IdentityServiceBroker.IdentityProvider{}, ...]

  """
  def list_identity_providers() do
    IdentityServiceBroker.list_identity_providers()
  end
end
