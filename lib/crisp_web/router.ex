defmodule CrispWeb.Router do
  use CrispWeb, :router

  import CrispWeb.Authentication
  import CrispWeb.Onboarding

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_employee
    plug :check_onboarding_state
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Non-authenticated routes
  scope "/", CrispWeb do
    pipe_through [:browser, :redirect_authenticated_employee]

    get "/tunnistaudu", StrongAuthenticationController, :login
    get "/liity", StrongAuthenticationController, :registration
    get "/salasana/uusi", StrongAuthenticationController, :reset_password
    post "/tunnistaudu", StrongAuthenticationController, :create
    get "/callback", StrongAuthenticationController, :callback

    get "/kirjaudu", SessionController, :new
    post "/kirjaudu", SessionController, :create
  end

  scope "/", CrispWeb do
    pipe_through [:browser]

    get "/kayttoonotto/vahvistus/:token", EmailConfirmationController, :confirm
  end

  # Authenticated routes
  scope "/", CrispWeb do
    pipe_through [:browser, :require_authenticated_employee]

    # Onboarding, luo tunnarit
    get "/tunnukset", CredentialsController, :new
    post "/tunnukset", CredentialsController, :create

    get "/kayttoonotto/vahvistus", EmailConfirmationController, :show

    # /kayttoonotto/tunnukset
    get "/kayttoonotto/tiedot", PersonalInformationController, :new
    post "/kayttoonotto/tiedot", PersonalInformationController, :create

    get "/", PageController, :index

    delete "/kirjaudu-ulos", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", CrispWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CrispWeb.Telemetry
    end
  end
end
