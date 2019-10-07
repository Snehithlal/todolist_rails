Rails.application.routes.draw do
  devise_for :users
  get 'todos/search'
  get 'todos/update'
  post 'todos/update'
  post 'todos/status_update'
  post 'todos/checkactive'
  post 'todos/change_position'
  resources :todos
  resources :todos do
   resources :comments
 end
  root 'todos#index'
end
