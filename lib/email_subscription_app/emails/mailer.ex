defmodule EmailSubscriptionApp.Emails.Mailer do
  use Swoosh.Mailer, otp_app: :email_subscription_app
end

# defmodule EmailSubscriptionApp.Emails.Mailer do
#   use Swoosh.Mailer, otp_app: :email_subscription_app

#   def deliver_with_simulation(email, config \\ []) do
#     if Application.get_env(:email_subscription_app, :simulate_mailer_failure, false) do
#       {:error, "Simulated email delivery failure"}
#     else
#       deliver(email, config)
#     end
#   end
# end
