defmodule CrispWeb.InvoiceView do
  use CrispWeb, :view

  def users do
    Crisp.Users.list_users()
    |> Enum.map(fn user -> [value: user.id, key: user.name] end)
  end
end
