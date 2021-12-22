# frozen_string_literal: true

require 'swagger_helper'

describe 'Auth API', swagger_doc: 'v1/swagger.yaml' do
  let(:user_obj) { build(:user) }
  let(:username) { user_obj.username }
  let(:email) { user_obj.email }
  let(:password) { user_obj.password }
  let(:user) { { username: username, email: email, password: password } }

  path '/api/v1/auth/' do
    post 'Creates a user' do
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
        # examples 'application/json' => {
        #   id: 1,
        #   title: 'Hello world!',
        #   content: '...'
        # }
        # after do |example|
        #   puts "HELLO"
        #   example.metadata[:response][:content] = {
        #     'application/json' => {
        #       example: JSON.parse(response.body, symbolize_names: true)
        #     }
        #   }
        # end

        run_test! do
          expect(User.count).to eq(1)
        end
      end

      # response '422', 'incorrect email or username; email and/or username has already been taken' do
      #   context 'email has taken' do
      #     before do |example|
      #       create :user, email: email
      #       submit_request(example.metadata)
      #     end
      #
      #     it 'returns expected response' do |example|
      #       assert_response_matches_metadata(example.metadata)
      #       expect(response.body).to include('Email has already been taken')
      #     end
      #   end
      #
      #   context 'username has taken' do
      #     before do |example|
      #       create :user, username: username
      #       submit_request(example.metadata)
      #     end
      #
      #     it 'returns expected response' do |example|
      #       assert_response_matches_metadata(example.metadata)
      #       expect(response.body).to include('Username has already been taken')
      #     end
      #   end
      #
      #   context 'username is too short (less than 3 symbols)' do
      #     let(:username) { Faker::Internet.username(specifier: 1..2) }
      #
      #     before do |example|
      #       submit_request(example.metadata)
      #     end
      #
      #     it 'returns expected response' do |example|
      #       assert_response_matches_metadata(example.metadata)
      #       expect(response.body).to include('Username is too short')
      #     end
      #   end
      #
      #   context 'email is invalid' do
      #     let(:email) { Faker::Internet.username }
      #
      #     before do |example|
      #       submit_request(example.metadata)
      #     end
      #
      #     it 'returns expected response' do |example|
      #       assert_response_matches_metadata(example.metadata)
      #       expect(response.body).to include('Email is not an email')
      #     end
      #   end
      # end
      #
      # response '422', 'email has taken' do
      #   before do
      #     create :user, email: email
      #   end
      #
      #   run_test! do |response|
      #     expect(response.body).to include('Email has already been taken')
      #   end
      # end
      #
      # response '422', 'username has taken' do
      #   before do
      #     create :user, username: username
      #   end
      #
      #   run_test! do |response|
      #     expect(response.body).to include('Username has already been taken')
      #   end
      # end
      #
      # response '422', 'username is too short (less than 3 symbols)' do
      #   let(:username) { Faker::Internet.username(specifier: 1..2) }
      #
      #   run_test! do |response|
      #     expect(response.body).to include('Username is too short')
      #   end
      # end
      #
      # response '422', 'email is invalid' do
      #   let(:email) { Faker::Internet.username }
      #
      #   run_test! do |response|
      #     expect(response.body).to include('Email is not an email')
      #   end
      # end
    end
  end
end
