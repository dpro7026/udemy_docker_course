Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  resources :events
  devise_for :users
  get 'homepage/index'
  root 'events#index'
end
