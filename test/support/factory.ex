defmodule Crisp.Factory do
  alias Crisp.Repo

  alias Crisp.Employees.Employee
  alias Crisp.Accounts.Email

  def build(:employee) do
    %Employee{
      email: build(:email),
      onboarding_state: :create_account
    }
  end

  def build(:email) do
    %Email{
      address: "test@example.com",
      verification_token: "verification_token"
    }
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
