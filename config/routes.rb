Rails.application.routes.draw do
  devise_for :users
  get 'todos/search'
  post 'todos/search'
  get 'todos/update'
  post 'todos/update'
    post 'todos/update'
    post 'todos/checkactive'
  put 'todos/position_up'
  post 'todos/position_up'
  resources :todos
  root 'todos#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
