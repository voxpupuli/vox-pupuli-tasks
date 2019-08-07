require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'

  resources :repositories, only: %i[index show]

  get "/auth/:provider/callback", to: "sessions#create"

  get 'auth/failure', to: redirect('/')

  delete 'signout', to: 'sessions#destroy', as: 'signout'
  root to: 'dashboard#show'

  post 'incoming/github', to: 'incoming#github'

  constraints ->(req) { req.session['user_id'] } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
