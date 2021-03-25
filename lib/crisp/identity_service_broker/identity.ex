defmodule Crisp.IdentityServiceBroker.Identity do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :birthdate, :date
    field :given_name, :string
    field :family_name, :string
    field :name, :string
    field :personal_identity_code, :string
    field :nonce, :string
  end
end
