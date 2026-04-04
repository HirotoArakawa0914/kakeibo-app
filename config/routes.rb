Rails.application.routes.draw do
  root "transactions#index"
  resources :transactions
  resources :categories

  get "up" => "rails/health#show", as: :rails_health_check
end