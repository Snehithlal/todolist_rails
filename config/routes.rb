Rails.application.routes.draw do
  devise_for :users
  get 'todolists/search'
  post 'todolists/search'
  get 'todolists/update'
  post 'todolists/update'
  resources :todolists
  root 'todolists#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
