defmodule OPISB.IdentityProvider do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:imageUrl, :string)
    field(:name, :string)
    field(:ftn_idp_id, :string)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:imageUrl, :name, :ftn_idp_id])
    |> validate_required([:imageUrl, :name, :ftn_idp_id])
  end
end
