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
    invoice = get_changed_invoice(socket.assigns.changeset)
    rows = invoice.invoice_rows ++ [build_row()]

    changeset = Invoices.change_invoice(%{invoice | invoice_rows: rows})
    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("remove-row", %{"temp-id" => removable_id}, socket) do
    invoice = get_changed_invoice(socket.assigns.changeset)
    rows = Enum.filter(invoice.invoice_rows, fn row -> removable_id != row.temp_id end)

    changeset = Invoices.change_invoice(%{invoice | invoice_rows: rows})

    {
      :noreply,
      socket
      |> assign(changeset: changeset)
      |> assign(totals: calculate_totals(changeset))
    }
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
    |> assign(totals: calculate_totals(changeset))
    |> assign(changeset: changeset)
    |> assign(users: users)
  end

  # Getting invoice (and especially rows) has a minor inconvenience:
  # data is split in two fields depending on whether field has
  # any input in it: changeset.data or changeset.changes.
  #
  # Applying changes to Invoice schema to overcome this and
  # simplify code.
  defp get_changed_invoice(changeset) do
    invoice = Ecto.Changeset.apply_changes(changeset)

    rows =
      case invoice.invoice_rows do
        rows when is_list(rows) -> rows
        _ -> []
      end

    %{invoice | invoice_rows: rows}
  end

  defp calculate_totals(changeset) do
    invoice = get_changed_invoice(changeset)

    subtotal = Enum.reduce(invoice.invoice_rows, 0, fn row, acc -> acc + (row.amount || 0) end)
    vat_amount = Float.ceil(subtotal * 0.24, 2)
    total = Float.ceil(subtotal + vat_amount, 2)

    %{subtotal: subtotal, vat_amount: vat_amount, total: total}
  end

  defp build_row() do
    %InvoiceRow{temp_id: Ecto.UUID.generate()}
  end
end
