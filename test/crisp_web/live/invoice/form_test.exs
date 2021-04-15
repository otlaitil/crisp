defmodule CrispWeb.Live.InvoiceFormTest do
  use CrispWeb.ConnCase

  setup do
    {:ok, user} =
      Crisp.Users.create_user(%{
        name: "Otto"
      })

    valid_attrs = %{
      invoice: %{
        user_id: user.id,
        description: "January",
        invoice_rows: %{
          "0": %{
            amount: 100,
            title: "Consulting"
          }
        }
      }
    }

    {:ok, valid_attrs: valid_attrs}
  end

  test "renders", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/invoices/new")
    assert html =~ "New Invoice"
  end

  test "add rows", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/invoices/new")

    # testing with text search
    assert view
           |> element(".add-row")
           |> render_click() =~ "Row #1"

    # testing with html element search
    view
    |> element("a.add-row")
    |> render_click()

    assert view
           |> element(".row-2")
           |> has_element?()
  end

  test "remove rows", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/invoices/new")

    assert view
           |> element(".add-row")
           |> render_click() =~ "Row #1"

    assert view
           |> element(".add-row")
           |> render_click() =~ "Row #2"

    refute view
           |> element(".row-2 a.delete-row")
           |> render_click() =~ "Row #2"
  end

  test "renders totals after change", %{conn: conn, valid_attrs: valid_attrs} do
    {:ok, view, _html} = live(conn, "/invoices/new")

    view
    |> element("a.add-row")
    |> render_click()

    view
    |> element("form")
    |> render_change(valid_attrs)

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

  test "saves the invoice and redirects to show page", %{conn: conn, valid_attrs: valid_attrs} do
    {:ok, view, _html} = live(conn, "/invoices/new")

    view
    |> element("a.add-row")
    |> render_click()

    {_status, {:redirect, %{to: path}}} =
      view
      |> form("form", valid_attrs)
      |> render_submit()

    assert Regex.match?(~r/\/invoices\/\d+/, path)
  end
end
