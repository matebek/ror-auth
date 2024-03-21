Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Auth routes
  get "/login" => "auth#new"
  post "/login" => "auth#create"
  delete "/logout" => "auth#destroy"

  # User account routes
  get "/signup" => "users#new"
  post "/signup" => "users#create"
  delete "/shutdown" => "users#destroy"

  # Password reset routes
  get "/password-reset", to: "password_resets#new", as: "new_password_reset"
  post "/password-reset", to: "password_resets#create"
  get "/password-reset/:token", to: "password_resets#edit", as: "edit_password_reset"
  patch "/password-reset/:token", to: "password_resets#update"

  # Email verification routes
  post "/email-verification", to: "email_verifications#create", as: "create_email_verification"
  get "/email-verification/:token", to: "email_verifications#update", as: "update_email_verification"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#welcome'
end
