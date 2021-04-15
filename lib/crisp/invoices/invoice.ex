defmodule Crisp.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Crisp.Users.User
  alias Crisp.Invoices.InvoiceRow

  schema "invoices" do
    field :amount, :integer
    field :description, :string

    belongs_to :user, User
    has_many :invoice_rows, InvoiceRow, on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:amount, :description, :user_id])
    |> cast_assoc(:invoice_rows)
    |> validate_required([:description, :user_id])
  end
end
