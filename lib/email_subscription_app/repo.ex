defmodule EmailSubscriptionApp.Repo do
  use Ecto.Repo,
    otp_app: :email_subscription_app,
    adapter: Ecto.Adapters.Postgres
end
