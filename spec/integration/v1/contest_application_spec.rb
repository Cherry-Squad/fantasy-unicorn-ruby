# frozen_string_literal: true

require 'swagger_helper'

describe 'ContestApplication API', type: :request do
  let(:contest_application) { { user_id: user.id, contest_id: contest.id } }

  path '/api/v1/contest_applications/' do
    let(:user) { create :user }
    let(:contest) { create :contest }

    post 'Create a contest application' do
      tags 'ContestApplication'

      response '201', 'contest application created' do
        include_context 'auth token'
        parameter name: :contest_application, in: :body, schema: {
          type: :object,
          properties: {
            user_id: { type: :integer },
            contest_id: { type: :integer }
          },
          required: %w[user_id contest_id]
        }
        let(:contest_application) { { user_id: user.id, contest_id: contest.id } }

        run_test!
      end

      response '400', 'contest application created' do
        include_context 'auth token'
        parameter name: :contest_application, in: :body, schema: {
          type: :object,
          properties: {
            user_id: { type: :integer },
            contest_id: { type: :integer }
          },
          required: %w[user_id contest_id]
        }
        let(:contest_application) { { user_id: nil, contest_id: contest.id } }
        run_test!
      end
    end

    get 'Get contest applications' do
      tags 'ContestApplication'

      response '200', 'get all contest applications' do
        include_context 'auth token'

        run_test!
      end
    end
  end

  path '/api/v1/contest_applications/{id}/' do
    let(:user) { create :user }
    let(:contest) { create :contest }
    let(:contest_application_obj) { create :contest_application }
    before do
      @user = contest_application_obj.user
    end

    delete 'delete a contest application' do
      tags 'ContestApplication'
      parameter name: :id, in: :path, type: :integer

      response '204', 'contest application successfully deleted' do
        auth_user

        let(:id) { contest_application_obj.id }

        run_test!
      end

      response '404', 'contest application not found' do
        auth_user

        let(:id) { 'invalid' }
        run_test!
      end
    end

    get 'Retrieve a contest application' do
      tags 'ContestApplication'
      parameter name: :id, in: :path, type: :integer

      response '200', 'contest application found' do
        auth_user

        let(:id) { contest_application_obj.id }
        run_test!
      end

      response '404', 'contest application not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
