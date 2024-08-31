defmodule EmailSubscriptionApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EmailSubscriptionAppWeb.Telemetry,
      EmailSubscriptionApp.Repo,
      {DNSCluster, query: Application.get_env(:email_subscription_app, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EmailSubscriptionApp.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: EmailSubscriptionApp.Finch},
      {Oban, Application.fetch_env!(:email_subscription_app, Oban)},
      # Start a worker by calling: EmailSubscriptionApp.Worker.start_link(arg)
      # {EmailSubscriptionApp.Worker, arg},
      # Start to serve requests, typically the last entry
      EmailSubscriptionAppWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EmailSubscriptionApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EmailSubscriptionAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
