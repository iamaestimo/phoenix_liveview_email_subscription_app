defmodule EmailSubscriptionApp.Subscriptions do
  alias EmailSubscriptionApp.Repo
  alias EmailSubscriptionApp.Subscriptions.Subscriber
  alias EmailSubscriptionApp.Workers.{WelcomeEmailWorker, FeaturesEmailWorker, OnboardEmailWorker}

  def subscribe(email) do
    %Subscriber{}
    |> Subscriber.changeset(%{email: email})
    |> Repo.insert()
    |> case do
      {:ok, subscriber} ->
        schedule_emails(subscriber)
        {:ok, subscriber}
      error -> error
    end
  end

  def unsubscribe(email) do
    Subscriber
    |> Repo.get_by(email: email)
    |> case do
      nil -> {:error, :not_found}
      subscriber ->
        Subscriber.changeset(subscriber, %{subscribed: false})
        |> Repo.update()
    end
  end

  defp schedule_emails(subscriber) do
    %{email: subscriber.email}
    |> WelcomeEmailWorker.new()
    |> Oban.insert()

    %{email: subscriber.email}
    |> FeaturesEmailWorker.new(schedule_in: 10 * 60)
    |> Oban.insert()

    %{email: subscriber.email}
    |> OnboardEmailWorker.new(schedule_in: 30 * 60)
    |> Oban.insert()
  end
end
