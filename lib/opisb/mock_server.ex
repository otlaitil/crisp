defmodule OPISB.MockServer do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/api/embedded-ui/:client_id" do
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
end
