# frozen_string_literal: true

require 'swagger_helper'

describe 'ContestApplication API', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/contest_applications/' do
    let!(:user) { create :user }
    let!(:contest) { create :contest }

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

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(ContestApplication.where(id: data['id'].to_i)).to exist
        end
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
      parameter name: :contest_id, in: :query, type: :integer, required: false
      tags 'ContestApplication'
      let!(:contest_application) { create :contest_application }

      before do
        @user = contest_application.user
      end

      response '200', 'get all contest applications for current user if contest_id not set otherwise returns all
                       contest applications by contest_id' do
        context 'contest_id presence in query' do
          auth_user

          let(:contest_id) { contest_application.contest.id }

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(ContestApplication.where(contest_id: contest_id).as_json(include: :user))
          end
        end

        context 'contest_id doesnt presence in query' do
          auth_user

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(ContestApplication.where(user: @user).as_json(include: :user))
          end
        end
      end
    end
  end

  path '/api/v1/contest_applications/{id}/' do
    let!(:contest) { create :contest }
    let!(:contest_application) { create :contest_application }
    before do
      @user = contest_application.user
    end

    delete 'delete a contest application' do
      tags 'ContestApplication'
      parameter name: :id, in: :path, type: :integer

      response '204', 'contest application successfully deleted' do
        auth_user

        let(:id) { contest_application.id }

        run_test! do
          expect(ContestApplication.where(id: id)).to_not exist
        end
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

        let(:id) { contest_application.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(ContestApplication.find_by(id: id).as_json)
        end
      end

      response '404', 'contest application not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
