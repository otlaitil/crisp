defmodule Crisp.Accounts.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :address, :string
    field :business_description, :string
    field :business_scope, :string
    field :city, :string
    field :firstname, :string
    field :iban, :string
    field :lastname, :string
    field :nationality, :string
    field :phonenumber, :string
    field :zip, :string
    has_one(:personal_identity, Crisp.Accounts.PersonalIdentity)
    has_one(:email, Crisp.Accounts.Email)

    timestamps()
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [
      :firstname,
      :lastname,
      :phonenumber,
      :nationality,
      :address,
      :city,
      :zip,
      :iban,
      :business_description,
      :business_scope
    ])
    |> validate_required([
      :firstname,
      :lastname,
      :phonenumber,
      :nationality,
      :address,
      :city,
      :zip,
      :iban,
      :business_description,
      :business_scope
    ])
  end
end
