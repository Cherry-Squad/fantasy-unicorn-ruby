# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authentication', type: :request do # rubocop:disable Metrics/BlockLength
  subject { create(:user) }
  # let(:username) { Faker::Internet.username }
  # let(:email) { Faker::Internet.email }
  # let(:password) { Faker::Internet.password(min_length: 6) }
  let(:username) { subject.username }
  let(:email) { subject.email }
  let(:password) { subject.password }

  context 'POST api/v1/auth (Sign Up process)' do
    it 'Should respond with status 200' do
      post api_v1_user_registration_path(username: 'username', email: 'email@mail.com', password: 'qwertyuiop')
      expect(response).to have_http_status(200)
    end

    it 'Should create database record' do
      expect do
        post api_v1_user_registration_path(username: username, email: email, password: password)
      end.to change(User, :count).by(1)
    end

    it 'Should respond with status 422 if user already created' do
      post api_v1_user_registration_path(username: username, email: email, password: password)
      expect(response).to have_http_status(422)
    end
  end

  context 'POST api/v1/auth/sign_in (Sign In process)' do
    it 'Should respond with status 200' do
      post api_v1_user_registration_path(username: username, email: email, password: password)
      post api_v1_user_session_path(email: email, password: password)
      expect(response).to have_http_status(200)
    end

    it 'Should respond with current_user in body' do
      post api_v1_user_registration_path(username: username, email: email, password: password)
      post api_v1_user_session_path(email: email, password: password)
      expect(response.body).to include(email, username)
    end

    it 'Should respond with status 401 if credentials are wrong' do
      post api_v1_user_registration_path(username: username, email: email, password: password)
      post api_v1_user_session_path(email: '', password: '')
      expect(response).to have_http_status(401)
    end

    it 'Should respond with error ' do
      post api_v1_user_registration_path(username: username, email: email, password: password)
      post api_v1_user_session_path(email: '', password: '')
      expect(response.body).to include('Invalid login credentials. Please try again')
    end
  end

  context 'DELETE api/v1/auth (Destroy user)' do
    it 'Should respond with status 200 with user auth_headers: access-token, client, uid' do
      post api_v1_user_registration_path(username: username, email: email, password: password)
      user = User.last
      auth_headers = user.create_new_auth_token
      delete api_v1_user_registration_path, headers: auth_headers
      expect(response).to have_http_status(200)
    end

    it 'Should respond with message: Account with UID email@example.com has been destroyed in body' do
      post api_v1_user_registration_path(username: username, email: email, password: password)
      user = User.last
      auth_headers = user.create_new_auth_token
      delete api_v1_user_registration_path, headers: auth_headers
      expect(response.body).to include('has been destroyed')
    end

    it 'Should respond with status 404 if user auth_headers not match with user' do
      auth_headers = {}
      delete api_v1_user_registration_path, headers: auth_headers
      expect(response).to have_http_status(404)
    end

    it 'Should respond with error in body if user auth_headers not match with user' do
      auth_headers = {}
      delete api_v1_user_registration_path, headers: auth_headers
      expect(response.body).to include('Unable to locate account for destruction')
    end
  end
end
