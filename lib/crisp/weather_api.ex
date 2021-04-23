defmodule Crisp.WeatherAPI do
  defmodule Interface do
    @type latlong :: {lat :: float, long :: float}
    @callback temp(latlong()) :: {:ok, integer()}
    @callback humidity(latlong()) :: {:ok, integer()}
  end

  @behaviour __MODULE__.Interface

  def temp(latlong), do: {:ok, 1}
  def humidity(latlong), do: {:ok, 1}
end
