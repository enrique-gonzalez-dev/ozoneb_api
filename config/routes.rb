Rails.application.routes.draw do
  # Devise routes (needed for password recovery)
  devise_for :users, skip: [:sessions, :registrations, :confirmations]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      # Health check
      get 'health', to: 'health#index'

      # Authentication routes
      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'

      # Password recovery routes
      post 'password/forgot', to: 'passwords#create'
      put 'password/reset', to: 'passwords#update'
      patch 'password/reset', to: 'passwords#update'

      # User management routes
      resources :users, only: [ :index, :show, :create, :update, :destroy ] do
        member do
          patch :update_password
          patch :update_avatar
        end
        collection do
          get :me
        end
      end

      # Current user endpoint
      get 'current_user', to: 'users#me'
    end
  end
end
