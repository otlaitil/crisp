defmodule OPISB do
  @moduledoc """
  """

  alias OPISB.{GetEmbeddedUi, Initiate, GetIdentity}

  @base_url Application.get_env(:opisb, :base_url)
  @client_id Application.get_env(:opisb, :client_id)
  @redirect_uri Application.get_env(:opisb, :redirect_uri)
  @signing_key Application.get_env(:opisb, :signing_key)
  @decrypt_key Application.get_env(:opisb, :decrypt_key)

  def get_embedded_ui() do
    url = GetEmbeddedUi.build_url(@base_url, @client_id)

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> GetEmbeddedUi.map_to_struct()

      error ->
        IO.inspect(error, label: "OPISB.get_embedded_ui/0")
    end
  end

  def initiate_identification(idp, opts \\ []) when is_binary(idp) do
    Initiate.claims(idp, @client_id, @redirect_uri, opts)
    |> Initiate.sign(@signing_key)
    |> Initiate.build_url(@base_url)
  end

  def get_identity(authorization_code) do
    request =
      GetIdentity.claims(@client_id, @redirect_uri)
      |> GetIdentity.sign(@signing_key)
      |> GetIdentity.build_request(@base_url, authorization_code)

    case HTTPoison.request(request) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        %{"id_token" => id_token} = Jason.decode!(body)
        decrypted_token = GetIdentity.decrypt(id_token, @decrypt_key)
        jwk = GetIdentity.jwks()
        claims = GetIdentity.verify(jwk, decrypted_token)
        GetIdentity.validate(claims)

      _ ->
        :error
    end
  end
end
