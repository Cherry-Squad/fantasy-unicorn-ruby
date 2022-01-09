# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  namespace :api do
    namespace :v1 do
      mount_devise_token_auth_for 'User', at: 'auth', controllers: {
        registrations: 'api/v1/auth/registration',
        sessions: 'api/v1/auth/sessions',
        confirmations: 'api/v1/auth/confirmations',
        passwords: 'api/v1/auth/passwords'
      }

      namespace :users do
        get '/', to: 'user#index'
        get '/scoreboard/', to: 'user#scoreboard'
        get '/:id(.:format)/', to: 'user#show'
        delete '/', to: 'user#delete'
        patch '/', to: 'user#update'
        get '/contest_applications/:id(.:format)/', to: 'contest_application#show'
      end

      namespace :briefcases do
        get '/', to: 'briefcase#index'
        get '/:id(.:format)/', to: 'briefcase#show'
        get '/:id(.:format)/stocks/', to: 'briefcase#show_stocks'
        post '/', to: 'briefcase#create'
        delete '/:id(.:format)/', to: 'briefcase#delete'
        patch '/:id(.:format)/', to: 'briefcase#update'
      end

      namespace :achievements do
        get '/', to: 'achievement#index'
        get '/:id(.:format)/', to: 'achievement#show'
        post '/', to: 'achievement#create'
        delete '/:id(.:format)/', to: 'achievement#delete'
        patch '/:id(.:format)/', to: 'achievement#update'
      end

      namespace :contests do
        get '/', to: 'contest#index'
        get '/:id(.:format)/', to: 'contest#show'
        post '/', to: 'contest#create'
        delete '/:id(.:format)/', to: 'contest#delete'
        patch '/:id(.:format)/', to: 'contest#update'
        post '/:id(.:format)/register/', to: 'contest_register#create'
      end

      namespace :stocks do
        get '/', to: 'stock#index'
        get '/suggestions/', to: 'stock#list'
        get '/:id(.:format)/', to: 'stock#show'
        get 'name/:name(.:format)/', to: 'stock#show_by_name'
        post '/', to: 'stock#create'
        delete '/:id(.:format)/', to: 'stock#delete'
        patch '/:id(.:format)/', to: 'stock#update'
      end

      namespace :contest_applications do
        get '/', to: 'contest_application#index'
        get '/:id(.:format)/', to: 'contest_application#show'
        post '/', to: 'contest_application#create'
        delete '/:id(.:format)/', to: 'contest_application#delete'
      end

      namespace :contest_application_stocks do
        get '/', to: 'contest_application_stock#index'
        get '/:id(.:format)/', to: 'contest_application_stock#show'
        post '/', to: 'contest_application_stock#create'
        delete '/:id(.:format)/', to: 'contest_application_stock#delete'
      end
    end
  end
end
