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
      parameter name: :fixed_direction_up, in: :query, type: :boolean, required: false, nullable: true
      parameter name: :use_briefcase_only, in: :query, type: :boolean, required: false, nullable: true
      parameter name: :use_disabled_multipliers, in: :query, type: :boolean, required: false, nullable: true
      parameter name: :use_inverted_stock_prices, in: :query, type: :boolean, required: false, nullable: true
      parameter name: :status, in: :query, type: :string, required: false, nullable: true
      parameter name: :direction_strategy, in: :query, type: :string, required: false, nullable: true
      parameter name: :coins_entry_fee_min_edge, in: :query, type: :integer, required: false, nullable: true
      parameter name: :coins_entry_fee_max_edge, in: :query, type: :integer, required: false, nullable: true
      parameter name: :max_fantasy_points_threshold, in: :query, type: :integer, required: false, nullable: true

      tags 'Contest'

      let!(:contest) { create :contest }
      let!(:contest2) { create :contest }
      let!(:contest3) { create :contest, status: 'finished' }
      let!(:contest4) { create :contest, coins_entry_fee: 30 }
      let!(:contest4) { create :contest, coins_entry_fee: 35 }
      let!(:contest5) { create :contest, max_fantasy_points_threshold: 50 }
      let!(:contest6) { create :contest, use_briefcase_only: true }
      let!(:contest7) { create :contest, direction_strategy: 'fixed' }
      let!(:contest8) { create :contest, direction_strategy: 'free' }

      response '200', 'get contests' do
        context 'all contests' do
          include_context 'auth token'

          let(:params) { {} }

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(Contest.all.as_json)
          end
        end

        context 'finished contests' do
          include_context 'auth token'

          let(:status) { 'finished' }

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(Contest.where(status: 'finished').as_json)
          end
        end
        context 'contests with coins_entry_fee between 20..40' do
          include_context 'auth token'

          let(:coins_entry_fee_min_edge) { 20 }
          let(:coins_entry_fee_max_edge) { 40 }

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(Contest.where(coins_entry_fee: (20..40)).as_json)
          end
        end
        context 'get contests by max_fantasy_points_threshold' do
          context 'get contests with max_fantasy_points_threshold = 20' do
            include_context 'auth token'

            let(:max_fantasy_points_threshold) { 20 }

            run_test! do |response|
              body = JSON(response.body)
              expect(body.as_json).to eq(Contest.none.as_json)
            end
          end
          context 'get contests with max_fantasy_points_threshold = 40' do
            include_context 'auth token'

            let(:max_fantasy_points_threshold) { 40 }

            run_test! do |response|
              body = JSON(response.body)
              expect(body.as_json).to eq(Contest.where(max_fantasy_points_threshold: (0..40)).as_json)
            end
          end
        end
        context 'use_briefcase_only contests' do
          include_context 'auth token'

          let(:use_briefcase_only) { true }

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(Contest.where(use_briefcase_only: true).as_json)
          end
        end
        context 'contests by direction_strategy' do
          context 'contest with free direction strategy' do
            include_context 'auth token'

            let(:direction_strategy) { 'free' }

            run_test! do |response|
              body = JSON(response.body)
              expect(body.as_json).to eq(Contest.where(direction_strategy: 'free').as_json)
            end
          end
          context 'contest with fixed direction strategy' do
            include_context 'auth token'

            let(:direction_strategy) { 'fixed' }

            run_test! do |response|
              body = JSON(response.body)
              expect(body.as_json).to eq(Contest.where(direction_strategy: 'fixed').as_json)
            end
          end
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
