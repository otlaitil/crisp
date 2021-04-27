defmodule Crisp.Employees.Employee do
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

    field :onboarding_state, Ecto.Enum,
      values: [
        :create_account,
        :confirm_email,
        :business_information,
        :complete
      ]

    has_one(:personal_identity, Crisp.Accounts.PersonalIdentity)
    has_one(:email, Crisp.Accounts.Email)

    timestamps()
  end

  def onboarding_changeset(employee, attrs) do
    employee
    |> cast(attrs, [:onboarding_state])
    |> validate_required([:onboarding_state])
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
      :business_scope,
      :onboarding_state
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
      :business_scope,
      :onboarding_state
    ])
  end
end
