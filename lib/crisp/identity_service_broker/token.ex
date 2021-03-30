defmodule Crisp.IdentityServiceBroker.Token do
  use Joken.Config

  def token_config do
    default_claims()
    |> add_claim("iss", fn -> "saippuakauppias" end, &(&1 == "saippuakauppias"))
    |> add_claim("client_id", fn -> "saippuakauppias" end, &(&1 == "saippuakauppias"))
  end
end
