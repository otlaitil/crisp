defmodule Crisp.Accounts.Session do
  use Ecto.Schema
  import Ecto.Query

  @rand_size 32
  @session_validity_in_days 7

  schema "sessions" do
    field :security, Ecto.Enum, values: [:weak, :strong]
    field :token, :binary
    belongs_to :employee, Crisp.Employees.Employee

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.
  """
  def build_token(employee, security) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %__MODULE__{token: token, security: security, employee_id: employee.id}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.
  The query returns the account found by the token.
  """
  def verify_token_query(token) do
    query =
      from session in __MODULE__,
        where: session.token == ^token,
        join: employee in assoc(session, :employee),
        where: session.inserted_at > ago(@session_validity_in_days, "day"),
        select: employee

    {:ok, query}
  end
end
