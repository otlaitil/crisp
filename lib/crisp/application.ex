defmodule Crisp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, args) do
    default_children = [
      # Start the Ecto repository
      Crisp.Repo,
      # Start the Telemetry supervisor
      CrispWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Crisp.PubSub},
      # Start the Endpoint (http/https)
      CrispWeb.Endpoint
      # Start a worker by calling: Crisp.Worker.start_link(arg)
      # {Crisp.Worker, arg}
    ]

    children =
      case args do
        [env: :dev] ->
          default_children ++ [OPISB.MockServer]

        [env: :test] ->
          default_children ++ [OPISB.MockServer]

        [env: :prod] ->
          default_children

        [_] ->
          []
      end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Crisp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CrispWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
