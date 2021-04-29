defmodule OPISB.GetEmbeddedUi do
  def build_request(base_url, client_id) do
    url =
      (base_url <> "/api/embedded-ui/" <> client_id)
      |> URI.parse()
      |> URI.to_string()

    %HTTPoison.Request{method: :get, url: url}
  end

  def map_to_struct(_map) do
    :ok
  end
end
