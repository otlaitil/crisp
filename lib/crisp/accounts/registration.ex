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

  def to_multi(params \\ %{}) do
    employee = Repo.get(Employee, 1)
    {_token, email_changeset} = Email.build(employee, params.email)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:email, email_changeset)
    |> Ecto.Multi.insert(:password, fn %{email: email} ->
      Ecto.build_assoc(email, :password)
      |> Password.changeset(%{plaintext: params.password})
    end)
  end

  def commit(params \\ %{}) do
    changeset = changeset(%__MODULE__{}, params)

    case Repo.transaction(to_multi(params)) do
      {:ok, _} ->
        :ok

      {:error, operation, multi_changeset, _changes} ->
        IO.inspect(operation, label: "operation")
        IO.inspect(multi_changeset)
        changeset = map_errors(operation, multi_changeset, changeset)
        {:error, changeset}
    end
  end

  defp map_errors(operation, from, to) do
    Enum.reduce(from.errors, to, fn {src_field, {msg, additional}}, acc ->
      dest_field = Map.fetch!(@error_map, {operation, src_field})
      Ecto.Changeset.add_error(acc, dest_field, msg, additional: additional)
    end)
  end
end
