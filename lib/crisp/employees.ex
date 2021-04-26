defmodule Crisp.Employees do
  @moduledoc """
  The Employees context.
  """

  alias Crisp.Repo
  alias Crisp.Accounts.Employee

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
end
