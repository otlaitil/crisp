defmodule OPISB.Claim do
  def initiate_claims(idp, client_id, redirect_uri, opts)
  when is_binary(idp) and is_binary(client_id) and is_binary(redirect_uri) do
    state = Keyword.get(opts, :state)
    nonce = Keyword.get(opts, :nonce)
    locale = Keyword.get(opts, :locale)
    exp = Keyword.get(opts, :exp, OPISB.Claim.expiration_time())

    %{
      "client_id" => client_id,
      "redirect_uri" => redirect_uri,
      "response_type" => "code",
      "scope" => "openid personal_identity_code profile",
      "ui_locales" => locale,
      "state" => state,
      "ftn_idp_id" => idp,
      "exp" => exp,
      "nonce" => nonce,
      "jti" => OPISB.Claim.generate_jti(),
      "iss" => client_id,
      "iat" => OPISB.Claim.current_time(),
      "nbf" => OPISB.Claim.current_time()
    }
    |> Enum.filter(fn {_, v} -> v end)
  end

  def current_time(), do: DateTime.utc_now() |> DateTime.to_unix()
  def expiration_time(), do: current_time() + 600

  @doc """
  Default function for generating `jti` claims. This was inspired by the
  `Plug.RequestId` generation. It avoids using `strong_rand_bytes` as it is
  known to have some contention when running with many schedulers.
  """
  def generate_jti() do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()}, 16_777_216)::24,
      :erlang.unique_integer()::32
    >>

    Base.hex_encode32(binary, case: :lower)
  end
end
