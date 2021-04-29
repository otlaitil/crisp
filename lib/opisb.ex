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
    request = GetEmbeddedUi.build_request(@base_url, @client_id)

    # TODO: Build %EmbeddedUI{} with list of %IdentityProvide{}
    case HTTPoison.request(request) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # TODO: Use Jason.decode/2 instead of Jason.decode!/2 and return :decode_error in case of failure
        body
        |> Jason.decode!()

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
      |> GetIdentity.build_request(authorization_code, @base_url)
      |> IO.inspect(label: "req")

    case HTTPoison.request(request) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        # TODO: Use Jason.decode/2 instead of Jason.decode!/2 and return :decode_error in case of failure
        %{"id_token" => id_token} = Jason.decode!(body)
        decrypted_token = GetIdentity.decrypt(id_token, @decrypt_key)

        # TODO: should be GetIdentity.jwks()
        jwk = JOSE.JWK.from_pem(@signing_key)

        # TODO: Use Jason.decode/2 instead of Jason.decode!/2 and return :decode_error in case of failure
        claims = GetIdentity.verify(jwk, Jason.decode!(decrypted_token))
        claims = GetIdentity.validate(claims)

        # TODO: Build Identity
        {:ok,
         %{
           birthdate: claims["birthdate"],
           name: claims["name"],
           personal_identity_code: claims["personal_identity_code"],
           nonce: claims["nonce"]
         }}

      _ ->
        :http_error
    end
  end
end
