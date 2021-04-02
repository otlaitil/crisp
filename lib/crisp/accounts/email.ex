defmodule Crisp.Accounts.Email do
  use Ecto.Schema
  import Ecto.Changeset

  @hash_algorithm :sha256
  @rand_size 64

  schema "emails" do
    field :address, :string
    field :verification_token, :binary
    field :verified_at, :naive_datetime
    belongs_to :employee, Crisp.Accounts.Employee

    timestamps()
  end

  @doc false
  def build(employee, params) do
    verification_token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, verification_token)

    changeset =
      Ecto.build_assoc(employee, :email)
      |> Map.put(:verification_token, hashed_token)
      |> cast(params, [:address])
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
end
