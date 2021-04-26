defmodule OPISB do
  @moduledoc """
  """

  @base_url "http://localhost:4010"
  @client_id "saippuakauppias"

  def get_embedded_ui() do
    url = @base_url <> "/api/embedded-ui/" <> @client_id

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      _ ->
        :error
    end
  end
end
