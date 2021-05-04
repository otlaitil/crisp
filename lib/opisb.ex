defmodule OPISB do
  @moduledoc """
  """

  alias OPISB.{GetEmbeddedUi, Initiate, GetIdentity, EmbeddedUi}

  @base_url Application.get_env(:opisb, :base_url)
  @client_id Application.get_env(:opisb, :client_id)
  @redirect_uri Application.get_env(:opisb, :redirect_uri)
  @signing_key Application.get_env(:opisb, :signing_key)
  @decrypt_key Application.get_env(:opisb, :decrypt_key)

  def get_embedded_ui(opts \\ []) do
    request = GetEmbeddedUi.build_request(@base_url, @client_id, opts)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.request(request),
         {:ok, decoded_body} <- Jason.decode(body),
         changeset <- EmbeddedUi.changeset(%EmbeddedUi{}, decoded_body),
         {:ok, embedded_ui} <- Ecto.Changeset.apply_action(changeset, :insert) do
      {:ok, embedded_ui}
    else
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Bad HTTP response", {status_code, body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Bad HTTP request", reason}

      {:error, %Jason.DecodeError{data: data}} ->
        {:error, "Invalid JSON", data}

      {:error, %Ecto.Changeset{errors: errors}} ->
        {:error, "Validation error", errors}
    end
  end

  def initiate_identification(idp, opts \\ []) when is_binary(idp) do
    Initiate.claims(idp, @client_id, @redirect_uri, opts)
    |> Initiate.sign(@signing_key)
    |> Initiate.build_url(@base_url)
  end

  def get_identity(authorization_code, _opts \\ []) do
    request =
      GetIdentity.claims(@client_id, @redirect_uri)
      |> GetIdentity.sign(@signing_key)
      |> GetIdentity.build_request(authorization_code, @base_url)

    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- HTTPoison.request(request),
         {:ok, %{"id_token" => id_token}} <- Jason.decode(body),
         decrypted_token <- GetIdentity.decrypt(id_token, @decrypt_key),
         jwk <- GetIdentity.jwks(@base_url),
         {:ok, decoded_token} <- Jason.decode(decrypted_token),
         {:ok, claims} <- GetIdentity.verify(jwk, decoded_token),
         {:ok, claims} <- GetIdentity.validate(claims, @client_id, @base_url) do
      # TODO: Build Identity
      {:ok,
       %{
         birthdate: claims.birthdate,
         name: claims.name,
         personal_identity_code: claims.personal_identity_code,
         nonce: claims.nonce
       }}
    else
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, "Bad HTTP response", {status_code, body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "Bad HTTP request", reason}

      {:error, %Jason.DecodeError{data: data}} ->
        {:error, "Invalid JSON", data}

      {:verify_error, error} ->
        {:error, "Verify error", error}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, "Validation error", changeset}
    end
  end
end
