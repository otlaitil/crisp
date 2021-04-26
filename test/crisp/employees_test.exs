defmodule CrispWeb.EmployeesTest do
  alias Crisp.Employees
  alias Crisp.Factory

  use CrispWeb.ConnCase

  describe "get/1" do
    setup do
      employee = Factory.insert!(:employee)
      %{employee: employee}
    end

    test "gets an Employee by id", %{employee: employee} do
      fetched_employee = Employees.get(employee.id)
      assert fetched_employee.id == employee.id
    end

    test "returns nil when Employee is not found with id" do
      fetched_employee = Employees.get(0)
      assert fetched_employee == nil
    end
  end
end
