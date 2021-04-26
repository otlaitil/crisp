ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Crisp.Repo, :manual)

Hammox.defmock(Crisp.MockWeatherAPI, for: Crisp.WeatherAPI.Interface)
