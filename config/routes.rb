# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/v1/auth/registration',
        sessions: 'api/v1/auth/sessions'
      }
      get 'briefcase/', to: 'briefcase#index'
      get 'briefcase/:id(.:format)/', to: 'briefcase#show'
      post 'briefcase/', to: 'briefcase#create'
      delete 'briefcase/:id(.:format)/', to: 'briefcase#delete'
      patch 'briefcase/:id(.:format)/', to: 'briefcase#update'

      get 'achievement/', to: 'achievement#index'
      get 'achievement/:id(.:format)/', to: 'achievement#show'
      post 'achievement/', to: 'achievement#create'
      delete 'achievement/:id(.:format)/', to: 'achievement#delete'
      patch 'achievement/:id(.:format)/', to: 'achievement#update'

      get 'contest/', to: 'contest#index'
      get 'contest/:id(.:format)/', to: 'contest#show'
      post 'contest/', to: 'contest#create'
      delete 'contest/:id(.:format)/', to: 'contest#delete'
      patch 'contest/:id(.:format)/', to: 'contest#update'

      get 'stock/', to: 'stock#index'
      get 'stock/:id(.:format)/', to: 'stock#show'
      post 'stock/', to: 'stock#create'
      delete 'stock/:id(.:format)/', to: 'stock#delete'
      patch 'stock/:id(.:format)/', to: 'stock#update'

      get 'contest_application/', to: 'contest_application#index'
      get 'contest_application/:id(.:format)/', to: 'contest_application#show'
      post 'contest_application/', to: 'contest_application#create'
      delete 'contest_application/:id(.:format)/', to: 'contest_application#delete'
      patch 'contest_application/:id(.:format)/', to: 'contest_application#update'

      get 'contest_application_stock/', to: 'contest_application_stock#index'
      get 'contest_application_stock/:id(.:format)/', to: 'contest_application_stock#show'
      post 'contest_application_stock/', to: 'contest_application_stock#create'
      delete 'contest_application_stock/:id(.:format)/', to: 'contest_application_stock#delete'
      patch 'contest_application_stock/:id(.:format)/', to: 'contest_application_stock#update'
    end
  end
end
