Rails.application.routes.draw do
  root "sessions#new" 

  get "signup", to: "users#new", as: "signup"
  post "users", to: "users#create"

  get "login", to: "sessions#new", as: "login"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"
  
  get "up" => "rails/health#show", as: :rails_health_check
  resources :games
end