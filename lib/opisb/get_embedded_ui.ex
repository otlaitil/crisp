defmodule OPISB.GetEmbeddedUi do
  def build_request(base_url, client_id, opts \\ []) do
    lang = Keyword.get(opts, :lang)

    query =
      %{"lang" => lang}
      |> Enum.filter(fn {_, v} -> v end)
      |> Enum.into(%{})

    url =
      (base_url <> "/api/embedded-ui/" <> client_id)
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(query))
      |> URI.to_string()

    %HTTPoison.Request{method: :get, url: url}
  end

  def map_to_struct(_map) do
    :ok
  end
end
