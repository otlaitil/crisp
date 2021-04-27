defmodule Crisp.Employees do
  @moduledoc """
  The Employees context.
  """

  alias Crisp.Repo

  alias Crisp.Employees.{
    Employee,
    Session
  }

  @doc """
  Gets an Employee by id.

  ## Examples

      iex> get(1)
      %Employee{id: 1}

      iex> get(0)
      nil

  """
  @spec get(integer()) :: Employee | nil
  def get(id) do
    Repo.get(Employee, id)
  end

  @doc """
  Gets an Employee by session token.

  ## Examples

      iex> get_by_session_token("valid-token")
      %Employee{}

      iex> get("invalid-token")
      nil

  """
  @spec get(String.t()) :: Employee | nil
  def get_by_session_token(token) do
    {:ok, query} = Session.verify_token_query(token)
    Repo.one(query)
  end
end
