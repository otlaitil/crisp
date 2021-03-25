defmodule Crisp.Accounts.AuthorizationCodeRequest do
  use Ecto.Schema
  import Ecto.Changeset

  @hash_algorithm :sha256
  @state_rand_size 32
  @nonce_rand_size 64

  schema "authorization_code_requests" do
    field :context, Ecto.Enum, values: [:registration]
    field :expired_at, :naive_datetime
    field :identity_provider_id, :string
    field :nonce, :binary
    field :state, :binary

    timestamps(updated_at: false)
  end

  @doc false
  def build(identity_provider_id) do
    expired_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(600, :second)
      |> NaiveDateTime.truncate(:second)

    state_token = :crypto.strong_rand_bytes(@state_rand_size)
    hashed_state_token = :crypto.hash(@hash_algorithm, state_token)

    nonce_token = :crypto.strong_rand_bytes(@nonce_rand_size)
    hashed_nonce_token = :crypto.hash(@hash_algorithm, nonce_token)

    {
      Base.url_encode64(state_token, padding: false),
      Base.url_encode64(nonce_token, padding: false),
      %__MODULE__{
        context: :registration,
        expired_at: expired_at,
        identity_provider_id: identity_provider_id,
        nonce: hashed_nonce_token,
        state: hashed_state_token
      }
    }
  end
end
