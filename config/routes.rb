require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'

  resources :repositories, only: [:index]

  get "/auth/:provider/callback", to: "sessions#create"

  get 'auth/failure', to: redirect('/')

  delete 'signout', to: 'sessions#destroy', as: 'signout'
  root to: 'dashboard#show'

  mount Sidekiq::Web => '/sidekiq'
end
