require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'rails/health#show'

  resources :carts, only: [:create], path: :cart do
    collection do
      get :show
      post :add_item
      delete ':product_id', to: 'carts#remove_item', as: :remove_item
    end
  end
end
