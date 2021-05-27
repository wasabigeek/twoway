Rails.application.routes.draw do
  get 'oauth_callbacks/notion'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'connections#index'

  resources :connections do
    collection do
      get 'notion', to: 'connections#notion'
    end
  end
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
end
