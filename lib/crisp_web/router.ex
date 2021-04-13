defmodule CrispWeb.Router do
  use CrispWeb, :router

  import CrispWeb.Authentication

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_employee
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Non-authenticated routes
  scope "/", CrispWeb do
    pipe_through [:browser, :redirect_authenticated_employee]

    get "/liity", AccountRegistrationController, :new
    post "/liity", AccountRegistrationController, :create

    get "/tunnistautuminen", AccountRegistrationController, :show

    get "/tunnukset", CredentialsController, :new
    post "/tunnukset", CredentialsController, :create

    get "/vahvistus/:token", EmailConfirmationController, :confirm

    get "/kirjaudu", SessionController, :new
    post "/kirjaudu", SessionController, :create
  end

  # Authenticated routes
  scope "/", CrispWeb do
    pipe_through [:browser, :require_authenticated_employee]

    get "/", PageController, :index
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
