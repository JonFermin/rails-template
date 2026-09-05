# frozen_string_literal: true

Rails.application.routes.draw do
  resource :session, only: %i[ new create destroy ]
  resources :passwords, param: :token, only: %i[ new create edit update ]

  resources :pets, only: %i[ index show ] do
    # Attendance events are actions on a pet, so they are singular nested resources rather than an Attendance CRUD.
    resource :check_in, only: :create, module: :pets
    resource :check_out, only: :create, module: :pets
    resources :daily_reports, only: %i[ new create ]
  end

  resources :daily_reports, only: :show do
    resource :activity_summary, only: :create
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "pets#index"
end
