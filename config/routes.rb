Rails.application.routes.draw do
  get "dashboard/index"
  root "transactions#index"
  resources :transactions
  resources :categories

  get "dashboard", to: "dashboard#index", as: :dashboard

  get "up" => "rails/health#show", as: :rails_health_check
end