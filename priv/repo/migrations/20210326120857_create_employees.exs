defmodule Crisp.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :firstname, :string
      add :lastname, :string
      add :phonenumber, :string
      add :nationality, :string
      add :address, :string
      add :city, :string
      add :zip, :string
      add :iban, :string
      add :business_description, :string
      add :business_scope, :string

      timestamps()
    end
  end
end
