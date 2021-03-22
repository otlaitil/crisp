defmodule Crisp.IdentityServiceBroker.IdentityProvider do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :id, :string
    field :name, :string
    field :image_url, :string
  end

  def from_json(data) when is_binary(data) do
    Jason.decode!(data)
    |> from_json
  end

  def from_json(data) when is_map(data) do
    %__MODULE__{}
    |> cast(data, [:isbProviderInfo])
    |> apply_changes
  end
end
