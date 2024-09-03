defmodule EmailSubscriptionApp.Emails.EmailSender do
  import Swoosh.Email

  def welcome_email(email) do
    new()
    |> to(email)
    |> from({"Email Subscription App", "noreply@example.com"})
    |> subject("#1 - Welcome")
    |> text_body("Welcome to our amazing service! We're excited to have you on board.")
    |> html_body("<h1>Welcome to our amazing service!</h1><p>We're excited to have you on board.</p>")
  end

  def features_email(email) do
    new()
    |> to(email)
    |> from({"Email Subscription App", "noreply@example.com"})
    |> subject("#2 - Discover Our Amazing Features")
    |> text_body("Here are some of our great features: ...")
  end

  def onboard_email(email) do
    new()
    |> to(email)
    |> from({"Email Subscription App", "noreply@example.com"})
    |> subject("#3 - Great to Have You On Board!")
    |> text_body("We're thrilled to have you as part of our community. Let us know if you need anything!")
  end
end
