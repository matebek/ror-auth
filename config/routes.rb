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

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#welcome'
end
