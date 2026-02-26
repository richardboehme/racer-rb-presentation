Rails.application.routes.draw do
  resources :meetings, only: %i[index show]
  resources :participants, only: %i[index show]

  root "meetings#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
