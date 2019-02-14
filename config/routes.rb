Rails.application.routes.draw do
  resources :events
  devise_for :users
  get 'homepage/index'
  root 'events#index'
end
