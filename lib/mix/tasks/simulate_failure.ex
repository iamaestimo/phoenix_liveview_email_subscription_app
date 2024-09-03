# lib/mix/tasks/simulate_failure.ex
defmodule Mix.Tasks.SimulateFailure do
  use Mix.Task

  @shortdoc "Simulates different failure scenarios for the WelcomeEmailWorker"
  def run(args) do
    Mix.Task.run("app.start")

    case args do
      ["mailer"] ->
        simulate_mailer_failure()
      ["timeout"] ->
        simulate_timeout()
      _ ->
        Mix.shell().info("Usage: mix simulate_failure [mailer|timeout]")
    end
  end

  defp simulate_mailer_failure do
    Mix.shell().info("Simulating a mailer failure.")
    Application.put_env(:email_subscription_app, :simulate_mailer_failure, true)
    %{email: "test@example.com"}
    |> EmailSubscriptionApp.Workers.WelcomeEmailWorker.new()
    |> Oban.insert()
    Process.sleep(5000)  # Wait for the job to complete
    Application.put_env(:email_subscription_app, :simulate_mailer_failure, false)
  end

  defp simulate_timeout do
    Mix.shell().info("Simulating a timeout. This will take about 35 seconds.")
    Application.put_env(:email_subscription_app, :simulate_timeout, true)
    %{email: "test@example.com"}
    |> EmailSubscriptionApp.Workers.WelcomeEmailWorker.new()
    |> Oban.insert()
    Process.sleep(40_000)  # Wait for the job to complete
    Application.put_env(:email_subscription_app, :simulate_timeout, false)
  end
end
