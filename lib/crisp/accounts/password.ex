defmodule Crisp.Accounts.Password do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect, except: [:plaintext]}
  schema "passwords" do
    field :plaintext, :string, virtual: true
    field :hash, :string
    belongs_to :email, Crisp.Accounts.Email

    timestamps()
  end

  @doc """
  A account changeset for registration. It is important to validate the length
  of password. Otherwise databases may truncate the email without warnings,
  which could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def changeset(password, attrs, opts \\ []) do
    password
    |> cast(attrs, [:plaintext])
    |> validate_password(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:plaintext])
    |> validate_length(:plaintext, min: 12, max: 80)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    plaintext = get_change(changeset, :plaintext)

    if hash_password? && plaintext && changeset.valid? do
      changeset
      |> put_change(:hash, Argon2.hash_pwd_salt(plaintext))
      |> delete_change(:plaintext)
    else
      changeset
    end
  end
end
