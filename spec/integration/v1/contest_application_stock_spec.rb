# frozen_string_literal: true

require 'swagger_helper'

describe 'ContestApplicationStock API', type: :request do
  let(:contest_application) { { user_id: user.id, contest_id: contest.id } }
  let(:contest_application_stock_obj) { build(:contest_application_stock) }
  let(:multiplier) { contest_application_stock_obj.multiplier }
  let(:contest_application_stock) do
    { stock_id: stock.id, contest_application_id: contest_application.id, multiplier: multiplier }
  end
  let(:stock_obj) { build(:stock) }
  let(:name) { stock_obj.name }
  let(:stock) { { name: name } }

  path '/api/v1/contest_application_stocks/' do
    let(:contest_application) { create :contest_application }
    let(:stock) { create :stock }

    post 'Create a contest application stock' do
      tags 'ContestApplicationStock'

      response '201', 'contest application stock created' do
        include_context 'auth token'
        parameter name: :contest_application_stock, in: :body, schema: {
          type: :object,
          properties: {
            stock_id: { type: :integer },
            contest_application_id: { type: :integer },
            multiplier: { type: :float }
          },
          required: %w[multiplier stock_id contest_application_id]
        }
        let(:contest_application_stock) do
          { stock_id: stock.id, contest_application_id: contest_application.id, multiplier: multiplier }
        end

        run_test!
      end

      response '400', 'contest application stock created' do
        include_context 'auth token'
        parameter name: :contest_application_stock, in: :body, schema: {
          type: :object,
          properties: {
            stock_id: { type: :integer },
            contest_application_id: { type: :integer },
            multiplier: { type: :float }
          },
          required: %w[multiplier stock_id contest_application_id]
        }
        let(:contest_application_stock) do
          { stock_id: nil, contest_application_id: contest_application.id, multiplier: multiplier }
        end

        run_test!
      end
    end

    get 'Get contest application stock stocks' do
      tags 'ContestApplicationStock'

      response '200', 'get all contest application stocks' do
        include_context 'auth token'

        run_test!
      end
    end
  end

  path '/api/v1/contest_application_stocks/{id}/' do
    let(:contest_application) { create :contest_application }
    let(:stock) { create :stock }
    let(:contest_application_stock_obj) { create :contest_application_stock }

    delete 'delete a contest application stock' do
      tags 'ContestApplicationStock'
      parameter name: :id, in: :path, type: :integer

      response '204', 'contest application successfully deleted' do
        include_context 'auth token'

        let(:id) { contest_application_stock_obj.id }

        run_test!
      end

      response '404', 'contest application not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end

    get 'Retrieve a contest application stock' do
      tags 'ContestApplicationStock'
      parameter name: :id, in: :path, type: :integer

      response '200', 'contest application stock found' do
        include_context 'auth token'

        let(:id) { contest_application_stock_obj.id }

        run_test!
      end

      response '404', 'contest application stock not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
