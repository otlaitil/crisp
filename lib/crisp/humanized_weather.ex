defmodule Crisp.HumanizedWeather do
  @api Application.get_env(
         :crisp,
         :weather_api,
         Crisp.WeatherAPI
       )

  def temp(latlong) do
    {:ok, temp} = @api.temp(latlong)
    "Current temperature is #{temp} degrees"
  end

  def humidity(latlong) do
    {:ok, hum} = @api.humidity(latlong)
    "Current humidity is #{hum}%"
  end
end
