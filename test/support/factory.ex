defmodule Crisp.Factory do
  alias Crisp.Repo

  alias Crisp.Employees.{
    Employee,
    Session
  }

  alias Crisp.Accounts.{
    Email
  }

  def build(:employee) do
    %Employee{
      email: build(:email),
      firstname: "John",
      lastname: "Doe",
      onboarding_state: :create_account
    }
  end

  def build(:email) do
    %Email{
      address: "test@example.com",
      verification_token: "verification_token"
    }
  end

  def build(:session, %{employee: employee}) do
    {_token, session} = Session.build_token(employee, :strong)
    session
  end

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
