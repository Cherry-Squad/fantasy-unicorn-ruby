# frozen_string_literal: true

require 'swagger_helper'

describe 'Achievement API', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/achievements/' do
    post 'Create an achievement' do
      tags 'Achievement'

      response '201', 'achievement created' do
        include_context 'auth token'

        parameter name: :achievement, in: :body, schema: {
          type: :object,
          properties: {
            achievement_identifier: { type: :string }
          },
          required: %w[achievement_identifier]
        }

        let(:achievement) { { achievement_identifier: 42 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(Achievement.where(id: data['id'].to_i)).to exist
        end
      end
    end

    get 'Get all achievements' do
      tags 'Achievement'

      let(:user_obj) { create :user }
      before do
        @user = user_obj
      end

      let!(:achievement1) { create :achievement, user_id: user_obj.id }
      let!(:achievement2) { create :achievement, user_id: user_obj.id }

      response '200', 'get all achievement' do
        auth_user

        run_test! do |response|
          body = JSON.parse(response.body).map(&:as_json)
          expect(body).to include(achievement1.as_json)
          expect(body).to include(achievement2.as_json)
        end
      end
    end
  end
  path '/api/v1/achievements/{id}/' do
    let(:achievement) { create :achievement }

    before do
      @user = achievement.user
    end

    delete 'delete an achievement' do
      tags 'Achievement'
      parameter name: :id, in: :path, type: :integer, required: true

      response '204', 'achievement successfully deleted' do
        auth_user

        let(:id) { achievement.id }

        run_test! do
          expect(Achievement.where(id: id)).to_not exist
        end
      end

      response '404', 'Not found 404' do
        auth_user
        let(:id) { 'invalid' }

        run_test!
      end
    end

    get 'Retrieve an achievement' do
      tags 'Achievement'
      parameter name: :id, in: :path, type: :integer

      response '200', 'achievement found' do
        auth_user

        let(:id) { achievement.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Achievement.find_by(id: id).as_json)
        end
      end

      response '404', 'achievement not found' do
        auth_user

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
