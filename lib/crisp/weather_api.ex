defmodule Crisp.WeatherAPI do
  @type latlong :: {lat :: integer, long :: integer}
  @callback temp(latlong()) :: {:ok, :temp, integer()}
  @callback humidity(latlong()) :: {:ok, integer()}

  def temp(latlong), do: {:ok, 1}
  def humidity(latlong), do: {:ok, 1}
end
