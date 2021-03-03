defmodule Crisp.Users.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Crisp.Invoices.Invoice

  schema "users" do
    field :name, :string
    has_many(:invoices, Invoice)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
