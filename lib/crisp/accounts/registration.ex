defmodule Crisp.Accounts.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Crisp.Accounts.{Employee, Email, Password}
  alias Crisp.Repo

  @required_fields [:email, :password]
  @error_map %{
    {:email, :address} => :email,
    {:password, :plaintext} => :password
  }

  embedded_schema do
    field(:email, :string)
    field(:password, :string)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
  end

  def to_multi(%Employee{} = employee, params \\ %{}) do
    {_token, email_changeset} = Email.build(employee, params["email"])

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:email, email_changeset)
    |> Ecto.Multi.insert(:password, fn %{email: email} ->
      Ecto.build_assoc(email, :password)
      |> Password.changeset(%{plaintext: params["password"]})
    end)
  end

  def commit(%Employee{} = employee, params \\ %{}) do
    changeset = changeset(%__MODULE__{}, params)

    case Repo.transaction(to_multi(employee, params)) do
      {:ok, %{email: email}} ->
        {:ok, email}

      {:error, operation, multi_changeset, _changes} ->
        map_errors(operation, multi_changeset, changeset)
        |> Ecto.Changeset.apply_action(:insert)
    end
  end

  defp map_errors(operation, from, to) do
    Enum.reduce(from.errors, to, fn {src_field, {msg, additional}}, acc ->
      dest_field = Map.fetch!(@error_map, {operation, src_field})
      Ecto.Changeset.add_error(acc, dest_field, msg, additional: additional)
    end)
  end
end
