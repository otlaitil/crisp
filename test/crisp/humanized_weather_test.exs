defmodule Crisp.HumanizedWeatherTest do
  use ExUnit.Case, async: true

  import Hammox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  test "gets and formats temperature and humidity" do
    Crisp.MockWeatherAPI
    |> expect(:temp, fn {_lat, _long} -> {:ok, 30} end)
    |> expect(:humidity, fn {_lat, _long} -> {:ok, 60} end)

    assert Crisp.HumanizedWeather.temp({50.06, 19.94}) == "Current temperature is 30 degrees"

    assert Crisp.HumanizedWeather.humidity({50.06, 19.94}) == "Current humidity is 60%"
  end
end
