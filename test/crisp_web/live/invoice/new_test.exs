defmodule CrispWeb.Live.NewInvoiceTest do
  use CrispWeb.ConnCase

  test "it renders", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/invoices/new")
    assert html =~ "New Invoice"
  end

  test "it adds rows", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/invoices/new")

    assert view
           |> element("a#add-row")
           |> render_click() =~ "Row #1"

    assert view
           |> element("a#add-row")
           |> render_click() =~ "Row #2"
  end

  test "it removes rows", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/invoices/new")

    assert view
           |> element("a#add-row")
           |> render_click() =~ "Row #1"

    assert view
           |> element("a#add-row")
           |> render_click() =~ "Row #2"

    refute view
           |> element("a.delete-row")
           |> render_click() =~ "Row #2"
  end

  test "it renders totals after change", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/invoices/new")

    view
    |> element("a#add-row")
    |> render_click()

    view
    |> element("form")
    |> render_change(
      invoice: %{
        invoice_rows: %{
          "0": %{
            amount: 100
          }
        }
      }
    )

    assert view
           |> element(".totals .subtotal")
           |> render() =~ "100"

    assert view
           |> element(".totals .vat")
           |> render() =~ "24"

    assert view
           |> element(".totals .total")
           |> render() =~ "124"
  end
end
