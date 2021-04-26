defmodule OPISB.MockServer do
  @client_id Application.get_env(:opisb, :client_id)

  use Plug.Router

  plug :match
  plug :dispatch

  # TODO: Returns 404 when client_id is not found
  get "/api/embedded-ui/#{@client_id}" do
    body =
      Jason.encode!(%{
        "disturbanceInfo" => %{
          "header" => "Häiriöilmoitus",
          "text" => "Tässä on häiriöilmoituksen tilavaraus toteutuksen helpottamiseksi"
        },
        "identityProviders" => [
          %{
            "ftn_idp_id" => "idp",
            "imageUrl" => "http://localhost:4010/static/idp.svg",
            "name" => "Test IdP"
          }
        ],
        "isbConsent" =>
          "Tunnistautumisen yhteydessä palveluntarjoajalle välitetään: henkilötunnus, nimi.",
        "isbProviderInfo" =>
          "OP Tunnistuksen välityspalvelun tarjoaa OP Ryhmän osuuspankit ja OP Yrityspankki Oyj.",
        "privacyNoticeLink" => "https://isb-test.op.fi/privacy-info",
        "privacyNoticeText" => "OP tietosuojaseloste"
      })

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, body)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
