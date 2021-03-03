defmodule Crisp.Invoices.Invoice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Crisp.Users.User

  schema "invoices" do
    field :amount, :integer
    field :description, :string

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [:amount, :description, :user_id])
    |> validate_required([:amount, :description, :user_id])
  end
end
