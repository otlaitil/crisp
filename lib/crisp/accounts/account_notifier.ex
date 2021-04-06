defmodule Crisp.Accounts.AccountNotifier do
  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  defp deliver(to, body) do
    require Logger
    Logger.debug(body)
    {:ok, %{to: to, body: body}}
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(email, url) do
    deliver(email.address, """
    ==============================
    Hi #{email.address},
    You can confirm your account by visiting the URL below:
    #{url}
    If you didn't create an account with us, please ignore this.
    ==============================
    """)
  end
end
