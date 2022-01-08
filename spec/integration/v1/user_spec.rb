# frozen_string_literal: true

require 'swagger_helper'

describe 'User API', swagger_doc: 'v1/swagger.yaml' do
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
      let!(:user_obj) { create :user }
      before do
        @user = user_obj
      end

      tags 'User'

      response '201', 'user updated' do
        auth_user
        parameter name: :user, in: :body, schema: {
          type: :object,
          properties: {
            username: { type: :string },
            email: { type: :email },
            preferred_lang: { type: :string },
            fantasy_points: { type: :integer },
            coins: { type: :integer }
          }
        }

        let(:user) { { id: user_obj.id, username: 'test', coins: 3 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(User.find_by(id: data['id']).as_json['username']).to eq(user.as_json['username'])
          expect(User.find_by(id: data['id']).as_json['coins']).to eq(user.as_json['coins'])
        end
      end
    end
  end

  path '/api/v1/users/{id}/' do
    let!(:user) { create :user }

    get 'Retrieve a user' do
      tags 'User'
      parameter name: :id, in: :path, type: :integer

      response '200', 'user found' do
        include_context 'auth token'

        let(:id) { user.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(User.find_by(id: id).as_json)
        end
      end

      response '404', 'stock not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/users/contest_applications/{id}/' do
    let!(:contest_application) { create :contest_application }
    let!(:contest) { contest_application.contest }
    before do
      @user = contest_application.user
    end

    get 'Get contest application for current user by id' do
      tags 'User'
      parameter name: :id, in: :path, type: :integer

      response '200', 'get contest application by id' do
        auth_user

        let(:id) { contest_application.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(ContestApplication.find_by(id: id).as_json)
        end
      end
    end
  end

  path '/api/v1/users/scoreboard/' do
    let(:count_of_users) { Faker::Number.within(range: 5..10) }
    let!(:users) { create_list(:user_with_points, count_of_users) }

    get 'Get users ordered by fantasy_points' do
      tags 'User'

      response '200', 'get users' do
        include_context 'auth token'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to eq(User.order('fantasy_points DESC').as_json)
        end
      end
    end
  end
end
