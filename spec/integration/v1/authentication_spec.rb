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

      security []

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

    delete 'Delete a user' do
      tags 'Auth'

      response '200', 'user successfully deleted' do
        include_context 'auth token'

        run_test! do
          expect(User.count).to eq(0)
        end
      end

      response '404', 'credentials are invalid' do
        include_context 'auth token'
        let(:"Access-Token") { 'not-token' }

        run_test! do
          expect(User.count).to eq(1)
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

      security []

      response '200', 'logged in' do
        let!(:confirmed) { user_obj.confirm }

        header 'access-token', type: :string, description: 'Access token'
        header 'client', type: :string, description: 'Client token'
        header 'uid', type: :string, description: 'User identifier'
        header 'expiry', type: :string, description: 'Token expiry timestamp'

        run_test!
      end

      response '401', 'credentials are invalid; email is not confirmed' do
        context 'with valid credentials and unconfirmed email' do
          run_test! do
            expect(response.body).to include('A confirmation email was sent')
          end
        end

        context 'with invalid password and unconfirmed email' do
          let(:password) { Faker::Internet.email }

          run_test! do
            expect(response.body).to include('A confirmation email was sent')
          end
        end

        context 'email is invalid' do
          let(:email) { Faker::Internet.username }

          run_test! do
            expect(response.body).to include('Invalid login credentials. Please try again')
          end
        end

        context 'password is invalid' do
          let(:password) { Faker::Internet.email }
          let!(:confirmed) { user_obj.confirm }

          run_test! do
            expect(response.body).to include('Invalid login credentials. Please try again')
          end
        end

        context 'no credentials' do
          let(:email) { '' }
          let(:password) { '' }

          run_test! do
            expect(response.body).to include('Invalid login credentials. Please try again')
          end
        end
      end
    end
  end

  path '/api/v1/auth/sign_out' do
    delete 'Sign out' do
      tags 'Auth'

      response '200', 'signed out' do
        include_context 'auth token'

        run_test!
      end

      response '404', 'credentials are invalid' do
        include_context 'auth token'
        let(:"Access-Token") { 'not-token' }

        run_test!
      end
    end
  end

  path '/api/v1/auth/validate_token' do
    get 'Validate token' do
      tags 'Auth'

      response '200', 'token is valid' do
        include_context 'auth token'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['data']['email']).to eq(email)
        end
      end

      response '401', 'credentials are invalid' do
        include_context 'auth token'
        let(:"Access-Token") { 'not-token' }

        run_test!
      end
    end
  end

  path '/api/v1/auth/confirmation' do
    post 'Resend confirmation' do
      tags 'Auth'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string }
        },
        required: %w[email]
      }
      let!(:user_obj) { create(:user) }
      let(:user) { { email: email } }

      security []

      response '200', 'confirmation sent' do
        run_test! do
          expect(response.body).to include('An email has been sent')
        end
      end

      response '404', 'email is invalid' do
        let(:email) { Faker::Internet.email }

        run_test! do
          expect(response.body).to include('Unable to find user')
        end
      end
    end
  end

  path '/api/v1/auth/password' do
    put 'Change password' do
      tags 'Auth'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          password: { type: :string },
          password_confirmation: { type: :string }
        },
        required: %w[password password_confirmation]
      }
      let(:user) { { password: password, password_confirmation: password } }

      response '200', 'password has been updated' do
        include_context 'auth token'

        run_test! do
          expect(response.body).to include('Your password has been successfully updated')
        end
      end

      response '422', "must fill out the fields password; doesn't match password" do
        include_context 'auth token'

        context 'not all fields' do
          let(:user) { { password: password } }

          run_test! do
            expect(response.body).to include('You must fill out the fields')
          end
        end

        context "password doesn't match" do
          let(:user) { { password: password, password_confirmation: password*2 } }

          run_test! do
            expect(response.body).to include("doesn't match")
          end
        end
      end

      response '401', 'unauthorized' do
        include_context 'auth token'
        let(:"Access-Token") { 'not-token' }

        run_test!
      end
    end
  end
end
