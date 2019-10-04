Rails.application.routes.draw do
  devise_for :users
  get 'todos/search'
  # post 'todos/search'
  get 'todos/update'
  post 'todos/update'
  post 'todos/status_update'
  post 'todos/checkactive'
  post 'todos/change_position'
  resources :todos
  root 'todos#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
