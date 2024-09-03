# defmodule EmailSubscriptionApp.Workers.WelcomeEmailWorker do
#   use Oban.Worker, queue: :default
#   require Logger

#   alias EmailSubscriptionApp.Emails.{EmailSender, Mailer}

#   @impl Oban.Worker
#   def perform(%Oban.Job{args: %{"email" => email}}) do
#     Logger.info("Sending welcome email to #{email}")

#     result = email
#     |> EmailSender.welcome_email()
#     |> Mailer.deliver()

#     case result do
#       {:ok, _} -> Logger.info("Welcome email sent successfully to #{email}")
#       {:error, reason} -> Logger.error("Failed to send welcome email to #{email}. Reason: #{inspect(reason)}")
#     end

#     result
#   end
# end

defmodule EmailSubscriptionApp.Workers.WelcomeEmailWorker do
  use Oban.Worker, queue: :default
  alias EmailSubscriptionApp.Emails.{EmailSender, Mailer}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"email" => email}}) do
    try do
      email
      |> EmailSender.welcome_email()
      |> Mailer.deliver()
      |> case do
        {:ok, _} -> :ok
        {:error, reason} ->
          raise "Mailer delivery error: #{inspect(reason)}"
      end
    rescue
      e in RuntimeError ->
        Appsignal.set_error(e, "Mailer delivery error", email: email)
        {:error, e.message}
    end
  end
end

# defmodule EmailSubscriptionApp.Workers.WelcomeEmailWorker do
#   use Oban.Worker, queue: :default
#   use Appsignal.Instrumentation.Decorators

#   alias EmailSubscriptionApp.Emails.{EmailSender, Mailer}

#   @impl Oban.Worker
#   @decorate transaction()
#   def perform(%Oban.Job{args: %{"email" => email}} = job) do
#     Appsignal.Span.set_name(Appsignal.Span.current(), "WelcomeEmailWorker#perform")
#     start_time = System.monotonic_time(:millisecond)

#     try do
#       # Set a timeout for the entire job
#       task = Task.async(fn -> do_perform(email) end)
#       case Task.yield(task, 30_000) || Task.shutdown(task) do
#         {:ok, result} ->
#           handle_result(result, email, job)
#         nil ->
#           handle_timeout(email, job)
#       end
#     rescue
#       error ->
#         Appsignal.Span.add_error(Appsignal.Span.current(), error, "WelcomeEmailWorker Error", __STACKTRACE__)
#         reraise error, __STACKTRACE__
#     after
#       duration = System.monotonic_time(:millisecond) - start_time
#       Appsignal.add_distribution_value("worker.duration", duration)
#     end
#   end

#   defp do_perform(email) do
#     email
#     |> EmailSender.welcome_email()
#     |> Mailer.deliver_with_simulation()
#   end

#   defp handle_result({:ok, _} = result, email, _job) do
#     span = Appsignal.Span.current()
#     Appsignal.Span.set_attribute(span, "email", email)
#     Appsignal.Span.set_attribute(span, "status", "sent")
#     result
#   end

#   defp handle_result({:error, reason} = result, email, job) do
#     span = Appsignal.Span.current()
#     Appsignal.Span.set_attribute(span, "email", email)
#     Appsignal.Span.set_attribute(span, "status", "failed")
#     Appsignal.Span.set_attribute(span, "reason", inspect(reason))
#     Appsignal.Span.set_attribute(span, "attempt", job.attempt)
#     Appsignal.Span.set_attribute(span, "max_attempts", job.max_attempts)

#     error = RuntimeError.exception("Email delivery failed")
#     Appsignal.Span.add_error(span, error, "External service failure in WelcomeEmailWorker", format_stacktrace())

#     result
#   end

#   defp handle_timeout(email, job) do
#     span = Appsignal.Span.current()
#     Appsignal.Span.set_attribute(span, "email", email)
#     Appsignal.Span.set_attribute(span, "status", "timeout")
#     Appsignal.Span.set_attribute(span, "attempt", job.attempt)
#     Appsignal.Span.set_attribute(span, "max_attempts", job.max_attempts)

#     error = RuntimeError.exception("Job timed out")
#     Appsignal.Span.add_error(span, error, "Timeout in WelcomeEmailWorker", format_stacktrace())

#     {:error, :timeout}
#   end

#   defp format_stacktrace do
#     Process.info(self(), :current_stacktrace)
#     |> elem(1)
#     |> Enum.drop(2)
#     |> Exception.format_stacktrace()
#   end
# end
