Rails.application.routes.draw do
  root "transactions#index"
  resources :transactions

  get "up" => "rails/health#show", as: :rails_health_check
end