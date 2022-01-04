
# frozen_string_literal: true

require 'swagger_helper'

describe 'Auth API', swagger_doc: 'v1/swagger.yaml' do
  let(:user_obj) { build(:user) }
  let(:username) { user_obj.username }
  let(:email) { user_obj.email }
  let(:password) { user_obj.password }
  let(:user) { { username: username, email: email, password: password } }

  path '/api/v1/user/' do

    get 'Get user' do
      tags 'User'

      response '200', 'get all users' do
        include_context 'auth token'

        run_test!
      end
    end

    patch 'update a user' do
      tags 'User'

      response '201', 'user updated' do
        include_context 'auth token'
        let(:user) { create :user }

        run_test!
      end

    end
  end

  path '/api/v1/user/{id}/' do
    let(:user) { create :user }

    get 'Retrieve a user' do
      tags 'User'
      parameter name: :id, in: :path, type: :integer

      response '200', 'stock found' do
        include_context 'auth token'

        let(:id) { user.id }
        run_test!
      end

      response '404', 'stock not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end

  end

end

