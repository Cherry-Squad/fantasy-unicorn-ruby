# frozen_string_literal: true

require 'swagger_helper'

describe 'Auth API', swagger_doc: 'v1/swagger.yaml' do
  let(:achievement_obj) { build(:achievement) }
  let(:achievement_identifier) { achievement_obj.achievement_identifier }
  let(:achievement) { { achievement_identifier: achievement_identifier} }

  path '/api/v1/achievement/' do
    post 'Create a achievement' do
      tags 'Achievement'

      response '201', 'achievement created' do
        include_context 'auth token'
        parameter name: :achievement, in: :body, schema: {
          type: :object,
          properties: {
            achievement_identifier: { type: :string },
          },
          required: %w[achievement_identifier]
        }

        run_test!
      end

    end

    get 'Get all achievements' do
      tags 'Achievement'

      response '200', 'get all achievement' do
        include_context 'auth token'

        run_test!
      end
    end
  end
  path '/api/v1/achievement/{id}/' do
    let(:achievement) { create :achievement }
    let(:user_obj) { achievement.user }
    before do
      @user = achievement.user
    end
    delete 'delete a achievement' do
      tags 'Achievement'
      parameter name: :id, in: :path, type: :integer, required: true

      response '204', 'achievement successfully deleted' do
        auth_user

        let(:id) { achievement.id }
        run_test!
      end

      response '404', 'Not found 404' do
        auth_user
        let(:id) { 'invalid' }

        run_test!
      end
    end

    get 'Retrieve a achievement' do
      tags 'Achievement'
      parameter name: :id, in: :path, type: :integer

      response '200', 'achievement found' do
        auth_user

        let(:id) { achievement.id }
        run_test!
      end

      response '404', 'achievement not found' do
        auth_user

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
