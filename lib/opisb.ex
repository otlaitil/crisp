defmodule OPISB do
  @moduledoc """
  """

  @base_url Application.get_env(:opisb, :base_url)
  @client_id Application.get_env(:opisb, :client_id)
  @redirect_uri Application.get_env(:opisb, :redirect_uri)
  @signing_key Application.get_env(:opisb, :signing_key)
  @decrypt_key Application.get_env(:opisb, :decrypt_key)

  def get_embedded_ui() do
    url = @base_url <> "/api/embedded-ui/" <> @client_id

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end
  end

  def initiate_identification(idp, opts \\ []) when is_binary(idp) do
    OPISB.Initiate.claims(idp, @client_id, @redirect_uri, opts)
    |> OPISB.Initiate.sign(@signing_key)
    |> OPISB.Initiate.build_url(@base_url)
  end

  def get_identity(authorization_code) do
    {url, body, headers} =
      OPISB.GetIdentity.claims(@client_id, @redirect_uri)
      |> OPISB.GetIdentity.sign(@signing_key)
      |> OPISB.GetIdentity.build_request(@base_url, authorization_code)

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"id_token" => id_token} = Jason.decode!(body)
        decrypted_token = OPISB.GetIdentity.decrypt(id_token, @decrypt_key)
        jwk = OPISB.GetIdentity.jwks()
        claims = OPISB.GetIdentity.verify(jwk, decrypted_token)
        OPISB.GetIdentity.validate(claims)

      _ ->
        :error
    end
  end
end
