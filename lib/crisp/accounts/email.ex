defmodule Crisp.Accounts.Email do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @hash_algorithm :sha256
  @rand_size 64
  @token_validity_in_days 7

  schema "emails" do
    field :address, :string
    field :verification_token, :binary
    field :verified_at, :naive_datetime
    belongs_to :employee, Crisp.Accounts.Employee
    has_one :password, Crisp.Accounts.Password

    timestamps()
  end

  @doc false
  def build(employee, email_address) do
    verification_token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, verification_token)

    changeset =
      Ecto.build_assoc(employee, :email)
      |> Map.put(:verification_token, hashed_token)
      |> change(address: email_address)
      |> validate_email()

    {Base.url_encode64(verification_token, padding: false), changeset}
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:address])
    |> validate_format(:address, ~r/^[^\s]+@[^\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> validate_length(:address, max: 160)
    |> unsafe_validate_unique(:address, Crisp.Repo)
    |> unique_constraint(:address)
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.
  The query returns the account found by the token.
  """
  def verify_email_query(token) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from email in __MODULE__,
            preload: [:employee],
            where: email.verification_token == ^hashed_token and is_nil(email.verified_at)

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(email) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(email, verified_at: now)
  end
end
