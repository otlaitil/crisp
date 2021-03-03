defmodule Crisp.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :amount, :integer
      add :description, :string
      add :user_id, references(:users)

      timestamps()
    end
  end
end
