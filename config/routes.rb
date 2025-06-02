require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount OasRails::Engine => '/docs'

  resources :products
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'rails/health#show'

  resources :carts, only: [:create], path: :cart do
    collection do
      get :show
      post :add_item
      delete ':product_id', to: 'carts#remove_item', as: :remove_item
      delete '/', to: 'carts#render_missing_param', as: :render_missing_param
    end
  end
end
