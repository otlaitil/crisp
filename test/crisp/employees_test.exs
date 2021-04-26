defmodule CrispWeb.EmployeesTest do
  alias Crisp.Employees
  alias Crisp.Employees.Employee
  alias Crisp.Factory

  use CrispWeb.ConnCase

  describe "get/1" do
    setup do
      employee = Factory.insert!(:employee)
      %{employee: employee}
    end

    test "gets Employee by given id", %{employee: %Employee{id: id} = employee} do
      assert %Employee{id: ^id} = Employees.get(id)
    end

    test "returns nil when Employee is not found" do
      assert Employees.get(0) == nil
    end
  end
end
