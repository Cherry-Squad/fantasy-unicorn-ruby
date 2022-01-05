# frozen_string_literal: true

require 'swagger_helper'

describe 'User API', swagger_doc: 'v1/swagger.yaml' do
  let(:user_obj) { build(:user) }
  let(:username) { user_obj.username }
  let(:email) { user_obj.email }
  let(:password) { user_obj.password }
  let(:user) { { username: username, email: email, password: password } }
  let(:contest_application) { { user_id: user.id, contest_id: contest.id } }

  path '/api/v1/users/' do
    get 'Get users' do
      tags 'User'

      response '200', 'get all users' do
        include_context 'auth token'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to eq(User.all.as_json)
        end
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

  path '/api/v1/users/{id}/' do
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

  path '/api/v1/users/contest_applications/{id}/' do
    let(:contest_application) { create :contest_application }
    let(:contest) { contest_application.contest }
    let(:user) { contest_application.user }
    before do
      @user = contest_application.user
    end

    get 'Get contest application for current user by id' do
      tags 'User'
      parameter name: :id, in: :path, type: :integer

      response '200', 'get contest application by id' do
        auth_user

        let(:id) { contest_application.id }

        run_test!
      end
    end
  end
end
