Rails.application.routes.draw do
  root "sessions#new" 

  get "signup", to: "users#new", as: "signup"
  post "users", to: "users#create"

  get "login", to: "sessions#new", as: "login"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"
  
  get "up" => "rails/health#show", as: :rails_health_check
  get "staff", to: "staff#index", as: "staff"
  get "dashboard", to: "dashboards#show", as: "dashboard"
  patch "update_role", to: "dashboards#update_role", as: "update_role"
  
  get "motivation", to: "actor_transactions#index", as: "motivation"

  resources :games do
    resource :report, only: [:new, :create, :show, :edit, :update]
  end

  resources :actor_transactions, only: [:create]

  namespace :api do
    resources :quests, only: [] do
      member do
        get 'timetable'
        post 'order'
      end
    end
  end
end