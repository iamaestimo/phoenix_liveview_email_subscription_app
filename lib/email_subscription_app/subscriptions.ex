defmodule EmailSubscriptionApp.Subscriptions do
  alias EmailSubscriptionApp.Repo
  alias EmailSubscriptionApp.Subscriptions.Subscriber
  alias EmailSubscriptionApp.Workers.{WelcomeEmailWorker, FeaturesEmailWorker, OnboardEmailWorker}

  def subscribe(email) do
    Appsignal.instrument("db.subscriber_creation", fn ->
      %Subscriber{}
      |> Subscriber.changeset(%{email: email})
      |> Repo.insert()
      |> case do
        {:ok, subscriber} ->
          Appsignal.increment_counter("subscription.success", 1)
          schedule_emails(subscriber)
          {:ok, subscriber}

        {:error, _changeset} = error ->
          Appsignal.increment_counter("subscription.failure", 1)
          error
      end
    end)
  end

  def unsubscribe(email) do
    Appsignal.instrument("database.subscriber_retrieval", fn ->
      Subscriber
      |> Repo.get_by(email: email)
      |> case do
        nil ->
          Appsignal.increment_counter("unsubscribe.not_found", 1)
          {:error, :not_found}
        subscriber ->
          Appsignal.instrument("database.subscriber_update", fn ->
            Subscriber.changeset(subscriber, %{subscribed: false})
            |> Repo.update()
            |> case do
              {:ok, _subscriber} ->
                {:ok, :unsubscribed}
              {:error, changeset} ->
                Appsignal.increment_counter("unsubscribe.failure", 1)
                {:error, changeset}
            end
          end)
      end
    end)
  end

  defp schedule_emails(subscriber) do
    Appsignal.instrument("email.schedule_welcome_email", fn ->
      %{email: subscriber.email}
      |> WelcomeEmailWorker.new()
      |> Oban.insert()
    end)

    Appsignal.instrument("email.schedule_features_email", fn ->
      %{email: subscriber.email}
      |> FeaturesEmailWorker.new(schedule_in: 10 * 60)
      |> Oban.insert()
    end)

    Appsignal.instrument("email.schedule_onboard_email", fn ->
      %{email: subscriber.email}
      |> OnboardEmailWorker.new(schedule_in: 30 * 60)
      |> Oban.insert()
    end)
  end
end
