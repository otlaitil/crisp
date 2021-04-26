defmodule Crisp.WeatherAPI do
  defmodule Interface do
    @type latlong :: {lat :: float, long :: float}
    @callback temp(latlong()) :: {:ok, integer()}
    @callback humidity(latlong()) :: {:ok, integer()}
    @callback maybe() :: :ok | :error
  end

  @behaviour __MODULE__.Interface

  def temp(_latlong), do: {:ok, 1}
  def humidity(_latlong), do: {:ok, 1}

  # NOTE
  #
  # Dialyzer *wont* warn about this function, because of success typing.
  # If one code path is correct, then its happy!
  def maybe() do
    a = Enum.random(0..1)

    if a == 1 do
      :ok
    else
      :not_part_of_the_callback
    end
  end
end
