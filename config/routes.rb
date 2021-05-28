Rails.application.routes.draw do
  get 'oauth_callbacks/notion'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'syncs#index'

  resources :connections do
    collection do
      get 'notion', to: 'connections#notion'
    end
  end
  resources :syncs do
    resources :notion_sync_sources, only: [:new, :create, :destroy]
    resources :gcal_sync_sources, only: [:new, :create, :destroy]
  end

  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
