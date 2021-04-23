ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Crisp.Repo, :manual)

Mox.defmock(Crisp.MockWeatherAPI, for: Crisp.WeatherAPI)
