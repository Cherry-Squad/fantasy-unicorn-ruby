# frozen_string_literal: true

require 'swagger_helper'

describe 'Auth API', swagger_doc: 'v1/swagger.yaml' do
  let(:user_obj) { build(:user) }
  let(:username) { user_obj.username }
  let(:email) { user_obj.email }
  let(:password) { user_obj.password }
  let(:user) { { username: username, email: email, password: password } }

  path '/api/v1/auth/' do
    post 'Create a user' do
      tags 'Auth'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          username: { type: :string },
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[username email password]
      }

      response '200', 'user created' do
        run_test! do
          expect(User.count).to eq(1)
        end
      end

      response '422', 'incorrect email or username; email and/or username has already been taken' do
        context 'email has taken' do
          before do
            create :user, email: email
          end

          run_test! do
            expect(response.body).to include('Email has already been taken')
          end
        end

        context 'username has taken' do
          before do
            create :user, username: username
          end

          run_test! do
            expect(response.body).to include('Username has already been taken')
          end
        end

        context 'username is too short (less than 3 symbols)' do
          let(:username) { Faker::Internet.username(specifier: 1..2) }

          run_test! do
            expect(response.body).to include('Username is too short')
          end
        end

        context 'email is invalid' do
          let(:email) { Faker::Internet.username }

          run_test! do
            expect(response.body).to include('Email is not an email')
          end
        end
      end
    end
  end

  path '/api/v1/auth/sign_in' do
    post 'Sign in' do
      tags 'Auth'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[email password]
      }
      let!(:user_obj) { create(:user) }
      let(:user) { { email: email, password: password } }

      response '200', 'logged in' do
        header 'access-token', type: :string, description: 'Access token'
        header 'client', type: :string, description: 'Client token'
        header 'uid', type: :string, description: 'User identifier'
        header 'expiry', type: :string, description: 'Token expiry timestamp'

        run_test!
      end

      response '401', 'credentials are invalid' do
        context 'email is invalid' do
          let(:email) { Faker::Internet.username }

          run_test! do
            expect(response.body).to include('Invalid login credentials. Please try again')
          end
        end

        context 'password is invalid' do
          let(:password) { Faker::Internet.email }

          run_test! do
            expect(response.body).to include('Invalid login credentials. Please try again')
          end
        end

        context 'no credentials' do
          let(:email) { Faker::Internet.username }
          let(:password) { Faker::Internet.email }

          run_test! do
            expect(response.body).to include('Invalid login credentials. Please try again')
          end
        end
      end
    end
  end
end
