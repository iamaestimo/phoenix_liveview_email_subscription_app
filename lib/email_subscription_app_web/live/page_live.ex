defmodule EmailSubscriptionAppWeb.PageLive do
  use EmailSubscriptionAppWeb, :live_view
  alias EmailSubscriptionApp.Subscriptions

  def mount(_params, _session, socket) do
    {:ok, assign(socket, email: "", subscribed: false, error: nil)}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8 text-center">
      <h1 class="text-4xl font-bold mb-4">Welcome to Our Email Subscription Service</h1>
      <p class="text-xl mb-8">Stay updated with our latest news and features!</p>

      <%= if @subscribed do %>
        <p class="text-green-600 font-semibold">Thank you for subscribing!</p>
      <% else %>
        <form phx-submit="subscribe" class="mb-4">
          <input type="email" name="email" value={@email} placeholder="Enter your email" required
                 class="px-4 py-2 border rounded-l-md focus:outline-none focus:ring-2 focus:ring-blue-500" />
          <button type="submit" class="px-4 py-2 bg-blue-500 text-white rounded-r-md hover:bg-blue-600">
            Subscribe
          </button>
        </form>
        <%= if @error do %>
          <p class="text-red-600"><%= @error %></p>
        <% end %>
      <% end %>
    </div>
    """
  end

  def handle_event("subscribe", %{"email" => email}, socket) do
    case Subscriptions.subscribe(email) do
      {:ok, _subscriber} ->
        {:noreply, assign(socket, email: "", subscribed: true, error: nil)}
      {:error, changeset} ->
        error = changeset.errors
                |> Enum.map(fn {field, {message, _}} -> "#{field} #{message}" end)
                |> Enum.join(", ")
        {:noreply, assign(socket, error: error)}
    end
  end
end
