defmodule EmailSubscriptionApp.Workers.FeaturesEmailWorker do
  use Oban.Worker, queue: :default

  alias EmailSubscriptionApp.Emails.{EmailSender, Mailer}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email}}) do
    email
    |> EmailSender.features_email()
    |> Mailer.deliver()

    :ok
  end
end
