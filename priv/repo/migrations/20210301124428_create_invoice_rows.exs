defmodule Crisp.Repo.Migrations.CreateInvoiceRows do
  use Ecto.Migration

  def change do
    create table(:invoice_rows) do
      add :title, :string
      add :amount, :integer
      add :invoice_id, references(:invoices)

      timestamps
    end
  end
end
