Rails.application.routes.draw do
  # Devise routes (needed for password recovery)
  devise_for :users, skip: [:sessions, :registrations, :confirmations]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :branches, only: [:index, :show, :create]
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
          get :inventory_preferences
          patch :update_inventory_preferences
          put :update_inventory_preferences
        end
      end
      get 'current_user', to: 'users#me'

  resources :products, only: [:index]
  resources :product_bases, only: [:index]
  resources :containers, only: [:index]
  resources :labels, only: [:index]

  # Hybrid routes: named resource routes that delegate to InventoryItemsController
  # Provide named helpers per STI type while keeping index routes in their own controllers.
  resources :products,      controller: 'inventory_items', defaults: { type: 'Product' }, only: [:create, :update, :destroy]
  resources :product_bases, controller: 'inventory_items', defaults: { type: 'ProductBase' }, only: [:create, :update, :destroy]
  resources :containers,    controller: 'inventory_items', defaults: { type: 'Container' }, only: [:create, :update, :destroy]
  resources :labels,        controller: 'inventory_items', defaults: { type: 'Label' }, only: [:create, :update, :destroy]
  resources :raw_materials, controller: 'inventory_items', defaults: { type: 'RawMaterial' }, only: [:create, :update, :destroy]
  resources :categories, only: [:index, :create, :destroy, :update]
  resources :raw_materials, only: [:index]

  # Inventory transactions routes
  resources :inventory_transactions, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
