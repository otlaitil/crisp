defmodule OPISB do
  @moduledoc """
  """

  @base_url Application.get_env(:opisb, :base_url)
  @client_id Application.get_env(:opisb, :client_id)
  @redirect_uri Application.get_env(:opisb, :redirect_uri)
  @signing_key Application.get_env(:opisb, :signing_key)

  def get_embedded_ui() do
    url = @base_url <> "/api/embedded-ui/" <> @client_id

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end
  end

  def initiate_identification(idp, opts \\ []) do
    OPISB.Initiate.claims(idp, @client_id, @redirect_uri, opts)
    |> OPISB.Initiate.sign(@signing_key)
    |> OPISB.Initiate.build_url(@base_url)
  end
end
