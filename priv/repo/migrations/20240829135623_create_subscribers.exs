defmodule EmailSubscriptionApp.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :email, :string, null: false
      add :subscribed, :boolean, default: true, null: false

      timestamps()
    end

    create unique_index(:subscribers, [:email])
  end
end
