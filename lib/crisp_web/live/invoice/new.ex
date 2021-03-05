defmodule CrispWeb.InvoiceLive.New do
  use CrispWeb, :live_view

  alias Crisp.Invoices
  alias Crisp.Invoices.Invoice
  alias Crisp.Invoices.InvoiceRow

  def render(assigns), do: Phoenix.View.render(CrispWeb.InvoiceView, "new.html", assigns)

  def mount(_params, _session, socket) do
    {:ok, assign_locals(socket)}
  end

  def handle_event("validate-and-calculate-totals", %{"invoice" => params}, socket) do
    changeset =
      %Invoice{}
      |> Invoices.change_invoice(params)
      |> Map.put(:action, :insert)

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
      |> assign(totals: calculate_totals(changeset))
    }
  end

  def handle_event("add-row", _params, socket) do
    existing_rows = socket.assigns.changeset.changes[:invoice_rows] || []
    updated_rows = existing_rows ++ [build_row()]

    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_assoc(:invoice_rows, updated_rows)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-row", %{"temp-id" => removable_id}, socket) do
    existing_rows = socket.assigns.changeset.changes[:invoice_rows] || []

    updated_rows = Enum.filter(existing_rows, fn row -> removable_id != row.changes[:temp_id] end)
    changeset = socket.assigns.changeset |> Ecto.Changeset.put_assoc(:invoice_rows, updated_rows)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"invoice" => params}, socket) do
    case Invoices.create_invoice(params) do
      {:ok, invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invoice created successfully.")
         |> redirect(to: Routes.invoice_path(socket, :show, invoice))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp assign_locals(socket) do
    invoice = %Invoice{}
    changeset = Invoices.change_invoice(invoice)
    users = CrispWeb.InvoiceView.users()

    socket
    |> assign(invoice: invoice)
    |> assign(totals: calculate_totals(changeset))
    |> assign(changeset: changeset)
    |> assign(users: users)
  end

  defp calculate_totals(changeset) do
    rows = Map.get(changeset.changes, :invoice_rows)

    if rows do
      subtotal = Enum.reduce(rows, 0, fn row, acc -> acc + (row.changes[:amount] || 0) end)
      vat_amount = Float.ceil(subtotal * 0.24, 2)
      total = Float.ceil(subtotal + vat_amount, 2)

      %{subtotal: subtotal, vat_amount: vat_amount, total: total}
    else
      %{subtotal: 0, vat_amount: 0, total: 0}
    end
  end

  defp build_row() do
    InvoiceRow.changeset(%InvoiceRow{}, %{temp_id: Ecto.UUID.generate()})
  end
end
