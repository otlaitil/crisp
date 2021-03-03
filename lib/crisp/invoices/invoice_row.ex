defmodule Crisp.Invoices.InvoiceRow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Crisp.Users.Invoice

  schema "invoice_rows" do
    field :title, :string
    field :amount, :integer

    belongs_to :invoice, Invoice

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:title, :amount, :invoice_id])
    |> validate_required([:title, :amount])
  end
end
