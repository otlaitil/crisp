defmodule Crisp.Invoices.InvoiceRow do
  use Ecto.Schema
  import Ecto.Changeset
  alias Crisp.Users.Invoice

  schema "invoice_rows" do
    field :title, :string
    field :amount, :integer
    field :delete, :boolean, virtual: true

    belongs_to :invoice, Invoice

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:title, :amount, :invoice_id, :delete])
    |> mark_for_destruction
    |> validate_required([:title, :amount])
  end

  defp mark_for_destruction(changeset) do
    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
