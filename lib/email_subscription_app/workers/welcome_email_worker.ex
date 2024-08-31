defmodule EmailSubscriptionApp.Workers.WelcomeEmailWorker do
  use Oban.Worker, queue: :default
  require Logger

  alias EmailSubscriptionApp.Emails.{EmailSender, Mailer}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email}}) do
    Logger.info("Sending welcome email to #{email}")

    result = email
    |> EmailSender.welcome_email()
    |> Mailer.deliver()

    case result do
      {:ok, _} -> Logger.info("Welcome email sent successfully to #{email}")
      {:error, reason} -> Logger.error("Failed to send welcome email to #{email}. Reason: #{inspect(reason)}")
    end

    result
  end
end
