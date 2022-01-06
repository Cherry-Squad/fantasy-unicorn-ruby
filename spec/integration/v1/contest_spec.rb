# frozen_string_literal: true

require 'swagger_helper'

describe 'Contest API', swagger_doc: 'v1/swagger.yaml' do
  let(:contest_obj) { build(:contest) }
  let(:coins_entry_fee) { contest_obj.coins_entry_fee }
  let(:direction_strategy) { contest_obj.direction_strategy }
  let(:fixed_direction_up) { contest_obj.fixed_direction_up }
  let(:max_fantasy_points_threshold) { contest_obj.max_fantasy_points_threshold }
  let(:status) { contest_obj.status }
  let(:summarizing_at) { contest_obj.summarizing_at }
  let(:use_briefcase_only) { contest_obj.use_briefcase_only }
  let(:use_disabled_multipliers) { contest_obj.use_disabled_multipliers }
  let(:use_inverted_stock_prices) { contest_obj.use_inverted_stock_prices }
  let(:reg_ending_at) { contest_obj.reg_ending_at }
  let(:contest) do
    {  coins_entry_fee: coins_entry_fee,
       direction_strategy: direction_strategy,
       fixed_direction_up: fixed_direction_up,
       max_fantasy_points_threshold: max_fantasy_points_threshold,
       status: status,
       reg_ending_at: reg_ending_at,
       summarizing_at: summarizing_at,
       use_briefcase_only: use_briefcase_only,
       use_disabled_multipliers: use_disabled_multipliers,
       use_inverted_stock_prices: use_inverted_stock_prices }
  end

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
        before do
          @contest = create :contest
        end

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Contest.last.as_json)
          expect { create :contest }.to change { Contest.count }.by(1)
        end
      end
    end

    get 'Get contests' do
      tags 'Contest'

      before do
        @contests = create_list(:contest, 3)
      end

      response '200', 'all contests' do
        include_context 'auth token'

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Contest.last(3).as_json)
        end
      end
    end
  end

  path '/api/v1/contests/{id}/' do
    delete 'delete a contest' do
      tags 'Contest'
      parameter name: :id, in: :path, type: :integer

      response '204', 'contest successfully deleted' do
        include_context 'auth token'

        let(:contest) { create :contest }
        let(:id) { contest.id }

        run_test! do
          expect { !Contest.find_by(id: id).exist? }
        end
      end

      response '404', 'contest not found' do
        include_context 'auth token'

        let(:contest) { create :contest }
        let(:id) { 'invalid' }
        run_test!
      end
    end

    get 'Retrieve a contest' do
      tags 'Contest'
      parameter name: :id, in: :path, type: :integer

      response '200', 'contest found' do
        include_context 'auth token'

        let(:contest) { create :contest }
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
