defmodule EmailSubscriptionApp.Subscriptions.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscribers" do
    field :email, :string
    field :subscribed, :boolean, default: true

    timestamps()
  end

  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:email, :subscribed])
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> unique_constraint(:email)
  end
end
