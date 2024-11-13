defmodule EmailSubscriptionApp.Workers.WelcomeEmailWorker do
  use Oban.Worker, queue: :default
  alias EmailSubscriptionApp.Emails.{EmailSender, Mailer}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email}}) do
    email
    |> EmailSender.welcome_email()
    |> Mailer.deliver()
    |> case do
      {:ok, _} -> :ok
      {:error, reason} ->
        raise "Mailer delivery error: #{inspect(reason)}"
    end
  end
end
