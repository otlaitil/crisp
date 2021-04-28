defmodule OPISB.GetEmbeddedUi do
  # TODO: build_request, instead of build_url
  def build_url(base_url, client_id) do
    (base_url <> "/api/embedded-ui/" <> client_id)
    |> URI.parse()
    |> URI.to_string()
  end

  def map_to_struct(_map) do
    :ok
  end
end
