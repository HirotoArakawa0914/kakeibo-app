Rails.application.routes.draw do
  root "transactions#index"

  resources :transactions do
    resources :receipts, only: [:new, :create], shallow: true
  end

  resources :categories
  resources :receipts, only: [:show, :destroy] do
    member do
      post :ocr
      get  :correct
      post :register
    end
  end

  get "dashboard", to: "dashboard#index", as: :dashboard
  get "up" => "rails/health#show", as: :rails_health_check
end