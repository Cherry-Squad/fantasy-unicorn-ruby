# frozen_string_literal: true

require 'swagger_helper'

describe 'Contest API', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/contests/' do
    post 'Create a contest' do
      tags 'Contest'

      response '201', 'contest created' do
        include_context 'auth token'
        parameter name: :contest, in: :body, schema: {
          type: :object,
          properties: {
            coins_entry_fee: { type: :integer },
            direction_strategy: { type: :string },
            fixed_direction_up: { type: :boolean },
            max_fantasy_points_threshold: { type: :integer },
            reg_ending_at: { type: :string },
            status: { type: :string },
            summarizing_at: { type: :string },
            use_briefcase_only: { type: :boolean },
            use_disabled_multipliers: { type: :boolean },
            use_inverted_stock_prices: { type: :boolean }
          },
          required: %w[coins_entry_fee direction_strategy fixed_direction_up max_fantasy_points_threshold
                       reg_ending_at status summarizing_at use_briefcase_only use_disabled_multipliers
                       use_inverted_stock_prices]
        }

        let(:contest) { build :contest }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(Contest.where(id: data['id'].to_i)).to exist
        end
      end
    end

    get 'Get contests' do
      tags 'Contest'

      let!(:contest) { create :contest }
      let!(:contest2) { create :contest }

      response '200', 'all contests' do
        include_context 'auth token'

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Contest.all.as_json)
        end
      end
    end
  end

  path '/api/v1/contests/{id}/' do
    let!(:contest) { create :contest }
    delete 'delete a contest' do
      tags 'Contest'
      parameter name: :id, in: :path, type: :integer

      response '204', 'contest successfully deleted' do
        include_context 'auth token'

        let(:id) { contest.id }

        run_test! do
          expect(Contest.where(id: id)).to_not exist
        end
      end

      response '404', 'contest not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end

    get 'Retrieve a contest' do
      tags 'Contest'
      parameter name: :id, in: :path, type: :integer

      response '200', 'contest found' do
        include_context 'auth token'

        let(:id) { contest.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Contest.find_by(id: id).as_json)
        end
      end

      response '404', 'contest not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
