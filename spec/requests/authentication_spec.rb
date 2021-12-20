# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  subject { build(:user) }
  let(:username) { subject.username }
  let(:email) { subject.email }
  let(:password) { subject.password }

  context 'POST api/v1/auth (Sign Up process)' do
    context 'With valid data' do
      it 'Should respond with status 200' do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        expect(response).to have_http_status(200)
      end

      it 'Should create database record' do
        expect do
          post api_v1_user_registration_path(username: username, email: email, password: password)
        end.to change(User, :count).by(1)
      end
    end

    context 'With email which already exist' do
      let(:email_old) { email }
      let(:username_new) { Faker::Internet.username(specifier: 3..20) }
      let(:password_new) { Faker::Internet.password(min_length: 6) }

      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        post api_v1_user_registration_path(username: username_new, email: email_old, password_new: password)
      end

      it 'Should respond with status 422' do
        expect(response).to have_http_status(422)
      end

      it 'Should respond with error ' do
        expect(response.body).to include('Email has already been taken')
      end
    end

    context 'With username which already exist' do
      let(:email_new) { Faker::Internet.email }
      let(:username_old) { username }
      let(:password_new) { Faker::Internet.password(min_length: 6) }

      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        post api_v1_user_registration_path(username: username_old, email: email_new, password: password_new)
      end

      it 'Should respond with status 422' do
        expect(response).to have_http_status(422)
      end

      it 'Should respond with error ' do
        expect(response.body).to include('Username has already been taken')
      end
    end

    context 'With username and email which already exist' do
      let(:email_old) { email }
      let(:username_old) { username }
      let(:password_new) { Faker::Internet.password(min_length: 6) }

      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        post api_v1_user_registration_path(username: username_old, email: email_old, password: password_new)
      end

      it 'Should respond with status 422' do
        expect(response).to have_http_status(422)
      end

      it 'Should respond with error ' do
        expect(response.body).to include('Username has already been taken', 'Email has already been taken')
      end
    end

    context 'With username which too short(less then 3 symbols)' do
      let(:username) { Faker::Internet.username(specifier: 1..2) }

      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
      end

      it 'Should respond with status 422' do
        expect(response).to have_http_status(422)
      end

      it 'Should respond with error ' do
        expect(response.body).to include('Username is too short')
      end
    end

    context 'With invalid email' do
      let(:email) { Faker::Internet.username }

      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
      end

      it 'Should respond with status 422' do
        expect(response).to have_http_status(422)
      end

      it 'Should respond with error ' do
        expect(response.body).to include('Email is not an email')
      end
    end
  end

  context 'POST api/v1/auth/sign_in (Sign In process)' do
    context 'With valid data' do
      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        post api_v1_user_session_path(email: email, password: password)
      end

      it 'Should respond with status 200' do
        expect(response).to have_http_status(200)
      end

      it 'Should respond with current_user in body' do
        expect(response.body).to include(email, username)
      end

      it 'Returns access-token in auth_headers' do
        expect(response.headers['access-token']).to be_present
      end

      it 'Returns client in auth_headers' do
        expect(response.headers['client']).to be_present
      end

      it 'Returns expiry in auth_headers' do
        expect(response.headers['expiry']).to be_present
      end

      it 'Returns uid in auth_headers' do
        expect(response.headers['uid']).to be_present
      end
    end

    context 'When email is invalid' do
      let(:invalid_email) { "invalid#{email}" }
      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        post api_v1_user_session_path(email: invalid_email, password: password)
      end

      it 'Should respond with status 401' do
        expect(response).to have_http_status(401)
      end

      it 'Should respond with error ' do
        expect(response.body).to include('Invalid login credentials. Please try again')
      end
    end

    context 'When password is invalid' do
      let(:invalid_password) { "invalid#{password}" }
      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        post api_v1_user_session_path(email: email, password: invalid_password)
      end

      it 'Should respond with status 401' do
        expect(response).to have_http_status(401)
      end

      it 'Should respond with error ' do
        expect(response.body).to include('Invalid login credentials. Please try again')
      end
    end

    context 'When blunk credentials' do
      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        post api_v1_user_session_path(email: '', password: '')
      end

      it 'Should respond with status 401' do
        expect(response).to have_http_status(401)
      end

      it 'Should respond with error ' do
        expect(response.body).to include('Invalid login credentials. Please try again')
      end
    end
  end

  context 'DELETE api/v1/auth (Destroy user)' do
    context 'With valid auth_headers' do
      before do
        post api_v1_user_registration_path(username: username, email: email, password: password)
        user = User.last
        auth_headers = user.create_new_auth_token
        delete api_v1_user_registration_path, headers: auth_headers
      end

      it 'Should respond with status 200 with user auth_headers: access-token, client, uid' do
        expect(response).to have_http_status(200)
      end

      it 'Should respond with message: Account with UID email@example.com has been destroyed in body' do
        expect(response.body).to include('has been destroyed')
      end
    end

    context 'Whith invalid auth_headers' do
      before do
        auth_headers = {}
        delete api_v1_user_registration_path, headers: auth_headers
      end

      it 'Should respond with status 404 if user auth_headers not match with user' do
        expect(response).to have_http_status(404)
      end

      it 'Should respond with error' do
        expect(response.body).to include('Unable to locate account for destruction')
      end
    end
  end

  context 'DELETE api/v1/auth/sign_out (Sign Out)' do
    it 'Should respond with status 200' do
      post api_v1_user_registration_path(username: username, email: email, password: password)
      user = User.last
      auth_headers = user.create_new_auth_token
      delete destroy_api_v1_user_session_path, headers: auth_headers
      expect(response).to have_http_status(200)
    end
  end
end
