defmodule Crisp.Accounts.Registration do
  use Ecto.Schema
  import Ecto.Changeset

  alias Crisp.Accounts.{AccountNotifier, Employee, Email, Password}
  alias Crisp.Repo

  @required_fields [:email, :password]
  @error_map %{
    {:email, :address} => :email,
    {:password, :plaintext} => :password
  }

  @primary_key false
  embedded_schema do
    field(:email, :string)
    field(:password, :string)
  end

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end

  def multi(%Employee{} = employee, %__MODULE__{} = registration, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    {token, email_changeset} = Email.build(employee, registration.email)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:email, email_changeset)
    |> Ecto.Multi.insert(:password, fn %{email: email} ->
      Ecto.build_assoc(email, :password)
      |> Password.changeset(%{plaintext: registration.password})
    end)
    |> Ecto.Multi.run(:instructions, fn _repo, %{email: email} ->
      AccountNotifier.deliver_confirmation_instructions(email, confirmation_url_fun.(token))
    end)
  end

  def map_errors(operation, from, to) do
    changeset =
      Enum.reduce(from.errors, to, fn {src_field, {msg, additional}}, acc ->
        dest_field = Map.fetch!(@error_map, {operation, src_field})
        Ecto.Changeset.add_error(acc, dest_field, msg, additional: additional)
      end)

    %{changeset | action: :insert}
  end
end
