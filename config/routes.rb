# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'

  resources :repositories, only: %i[index show]

  get '/auth/:provider/callback', to: 'sessions#create'

  get 'auth/failure', to: redirect('/')

  delete 'signout', to: 'sessions#destroy', as: 'signout'
  root to: 'dashboard#show'

  get 'about', to: 'dashboard#about'

  post 'incoming/github', to: 'incoming#github'

  post 'incoming/travis', to: 'incoming#travis'

  constraints ->(req) { req.session['user_id'] } do
    mount Sidekiq::Web => '/sidekiq'
  end
end
