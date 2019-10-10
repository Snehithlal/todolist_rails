Rails.application.routes.draw do
  devise_for :users
  get 'todos/search'
  post 'todos/status_update'
  post 'todos/change_position'
  resources :todos
  resources :todos do
   resources :comments
 end
  root 'todos#index'
end
