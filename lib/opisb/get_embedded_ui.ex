defmodule OPISB.GetEmbeddedUi do
  def build_url(base_url, client_id) do
    (base_url <> "/api/embedded-ui/" <> client_id)
    |> URI.parse()
    |> URI.to_string()
  end

  def map_to_struct(_map) do
    :ok
  end
end
