defmodule OPISB.EmbeddedUi do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    embeds_many(:identityProviders, OPISB.IdentityProvider)
    field(:isbConsent, :string)
    field(:isbProviderInfo, :string)
    field(:isbProviderLink, :string)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:isbConsent, :isbProviderInfo, :isbProviderLink])
    |> cast_embed(:identityProviders, required: true)
    |> validate_required([:identityProviders, :isbConsent, :isbProviderInfo, :isbProviderLink])
  end
end
