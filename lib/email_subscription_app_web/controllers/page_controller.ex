defmodule EmailSubscriptionAppWeb.PageController do
  use EmailSubscriptionAppWeb, :controller

  def home(conn, _params) do
    Appsignal.instrument("very slow request", fn ->
      :timer.sleep(5000)
      render(conn, :home, layout: false)
    end)
  end
end
