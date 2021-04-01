defmodule Crisp.Accounts.PersonalIdentity do
  use Ecto.Schema
  import Ecto.Changeset

  schema "personal_identities" do
    field :code, :string
    belongs_to :employee, Crisp.Accounts.Employee

    timestamps()
  end

  @doc false
  def changeset(personal_identity, attrs) do
    personal_identity
    |> cast(attrs, [:code])
    |> validate_required([:code])
  end
end
