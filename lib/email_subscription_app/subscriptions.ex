defmodule EmailSubscriptionApp.Subscriptions do
  alias EmailSubscriptionApp.Repo
  alias EmailSubscriptionApp.Subscriptions.Subscriber
  alias EmailSubscriptionApp.Workers.{WelcomeEmailWorker, FeaturesEmailWorker, OnboardEmailWorker}

  # require Logger

  def subscribe(email) do
    # Create a span for the subscriber creation process
    span = Appsignal.Tracer.create_span("database.subscriber_creation")

    # Wrap the logic inside a try-finally block to ensure the span is closed
    try do
      %Subscriber{}
      |> Subscriber.changeset(%{email: email})
      |> Repo.insert()
      |> case do
        {:ok, subscriber} ->
          # Increment success counter
          Appsignal.increment_counter("subscription.success", 1)

          # Optional: Add custom metadata to the span
          Appsignal.Span.set_attribute(span, "email", email)
          Appsignal.Span.set_attribute(span, "status", "success")

          # Schedule emails and return the result
          schedule_emails(subscriber)
          {:ok, subscriber}

        {:error, _changeset} = error ->
          # Increment failure counter
          Appsignal.increment_counter("subscription.failure", 1)

          # Optional: Add failure-specific metadata
          Appsignal.Span.set_attribute(span, "email", email)
          Appsignal.Span.set_attribute(span, "status", "failure")
          error
      end
    after
      # Finish the span, ensuring it gets closed even if an error occurs
      Appsignal.Tracer.close_span(span)
    end
  end


  def unsubscribe(email) do
    Appsignal.instrument("database.subscriber_retrieval", fn ->
      Subscriber
      |> Repo.get_by(email: email)
    end)
    |> case do
      nil ->
        Appsignal.increment_counter("unsubscribe.not_found", 1)
        {:error, :not_found}
      subscriber ->
        Appsignal.instrument("database.subscriber_update", fn ->
          Subscriber.changeset(subscriber, %{subscribed: false})
          |> Repo.update()
        end)
        |> case do
          {:ok, _subscriber} ->
            {:ok, :unsubscribed}
          {:error, changeset} ->
            Appsignal.increment_counter("unsubscribe.failure", 1)
            {:error, changeset}
        end
    end
  end

  defp schedule_emails(subscriber) do
    Appsignal.instrument("email.schedule_welcome", fn ->
      %{email: subscriber.email}
      |> WelcomeEmailWorker.new()
      |> Oban.insert()
    end)

    Appsignal.instrument("email.schedule_features", fn ->
      %{email: subscriber.email}
      |> FeaturesEmailWorker.new(schedule_in: 10 * 60)
      |> Oban.insert()
    end)

    Appsignal.instrument("email.schedule_onboard", fn ->
      %{email: subscriber.email}
      |> OnboardEmailWorker.new(schedule_in: 30 * 60)
      |> Oban.insert()
    end)
  end
end
