# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root 'activities#index'

  resource :session
  resources :accounts, only: %i[new create]
  resources :passwords, param: :token
  post 'verify_email_address/resend' => 'verify_email_addresses#resend', as: :resend_verify_email_address
  get 'verify_email_address/:token' => 'verify_email_addresses#show', as: :verify_email_address

  resources :activities, only: %i[index create destroy], constraints: { id: /.+/ }, format: false do
    collection do
      post 'pick'  # draws from user's own list
      post 'rogue' # draws from the app's list
    end
  end
end
