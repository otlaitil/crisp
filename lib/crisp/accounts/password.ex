defmodule Crisp.Accounts.Password do
  use Ecto.Schema
  import Ecto.Changeset

  schema "passwords" do
    field :hash, :string
    belongs_to :email, Crisp.Accounts.Email

    timestamps()
  end

  @doc false
  def changeset(password, attrs) do
    password
    |> cast(attrs, [:hash])
    |> validate_required([:hash])
  end
end
