defmodule Crisp.Onboarding do
  import Ecto.Query
  alias Crisp.Repo

  def change_employee_information(employee, attrs \\ %{}) do
  end

  # 1. Save employee information
  # 2. Save email and create confirmation_token
  # 3. Send confirmation_token via email
  def update_employee_information(employee, attrs, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
  end

  # 1.
  def confirm_email(token) do
  end
end
