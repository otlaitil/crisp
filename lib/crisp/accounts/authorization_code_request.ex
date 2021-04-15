defmodule Crisp.Accounts.AuthorizationCodeRequest do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @hash_algorithm :sha256
  @state_rand_size 32
  @nonce_rand_size 64

  schema "authorization_code_requests" do
    field :context, Ecto.Enum, values: [:registration, :login]
    field :expired_at, :naive_datetime
    field :identity_provider_id, :string
    field :nonce, :binary
    field :state, :binary

    timestamps(updated_at: false)
  end

  @doc false
  def build(identity_provider_id, context) do
    expired_at =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(600, :second)
      |> NaiveDateTime.truncate(:second)

    state_token = :crypto.strong_rand_bytes(@state_rand_size)
    hashed_state_token = :crypto.hash(@hash_algorithm, state_token)

    nonce_token = :crypto.strong_rand_bytes(@nonce_rand_size)
    hashed_nonce_token = :crypto.hash(@hash_algorithm, nonce_token)

    # TODO: Use changeset!
    {
      Base.url_encode64(state_token, padding: false),
      Base.url_encode64(nonce_token, padding: false),
      %__MODULE__{
        context: context |> String.to_existing_atom(),
        expired_at: expired_at,
        identity_provider_id: identity_provider_id,
        nonce: hashed_nonce_token,
        state: hashed_state_token
      }
    }
  end

  def get_by_state_query(state_token) do
    case Base.url_decode64(state_token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from r in __MODULE__,
            where: r.expired_at > ^NaiveDateTime.utc_now() and r.state == ^hashed_token

        {:ok, query}

      :error ->
        :error
    end
  end

  def verify_nonce(%__MODULE__{nonce: left}, right) do
    {:ok, decoded_nonce} = Base.url_decode64(right, padding: false)
    hashed_nonce = :crypto.hash(@hash_algorithm, decoded_nonce)

    if Plug.Crypto.secure_compare(left, hashed_nonce) do
      :ok
    else
      :mismatch
    end
  end
end
