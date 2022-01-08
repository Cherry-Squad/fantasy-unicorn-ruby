# frozen_string_literal: true

require 'swagger_helper'

describe 'ContestApplicationStock API', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/contest_application_stocks/' do
    let!(:contest_application) { create :contest_application }
    let!(:stock) { create :stock }

    post 'Create a contest application stock' do
      tags 'ContestApplicationStock'

      response '201', 'contest application stock created' do
        include_context 'auth token'
        parameter name: :contest_application_stock, in: :body, schema: {
          type: :object,
          properties: {
            stock_id: { type: :integer },
            contest_application_id: { type: :integer },
            multiplier: { type: :integer },
            direction_up: { type: :boolean }
          },
          required: %w[multiplier stock_id contest_application_id]
        }
        let(:contest_application_stock) do
          { stock_id: stock.id, contest_application_id: contest_application.id, multiplier: 10, direction_up: true }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(ContestApplicationStock.where(id: data['id'].to_i)).to exist
        end
      end

      response '400', 'contest application stock created' do
        include_context 'auth token'
        parameter name: :contest_application_stock, in: :body, schema: {
          type: :object,
          properties: {
            stock_id: { type: :integer },
            contest_application_id: { type: :integer },
            multiplier: { type: :integer },
            direction_up: { type: :boolean }
          },
          required: %w[multiplier stock_id contest_application_id]
        }
        let(:contest_application_stock) do
          { stock_id: nil, contest_application_id: contest_application.id, multiplier: 10, direction_up: true }
        end

        run_test!
      end
    end

    get 'Get contest application stock stocks' do
      tags 'ContestApplicationStock'
      let!(:contest_application) { create :contest_application }
      let!(:stock) { create :stock }
      let!(:contest_application2) { create :contest_application }
      let!(:stock2) { create :stock }

      response '200', 'get all contest application stocks if contest_id not set otherwise returns all
                       contest applications by contest_id' do
        let!(:contest_application_stock1) do
          create :contest_application_stock, contest_application_id: contest_application.id, stock_id: stock.id
        end
        let!(:contest_application_stock2) do
          create :contest_application_stock, contest_application_id: contest_application2.id, stock_id: stock2.id
        end

        context 'contest_id presence in query' do
          parameter name: :contest_id, in: :query, type: :integer, required: false
          include_context 'auth token'

          let(:contest_id) { contest_application_stock1.contest_application.contest.id }

          run_test! do |response|
            body = JSON.parse(response.body).map(&:as_json)
            expect(body).to include(contest_application_stock1.as_json)
            expect(body).to_not include(contest_application_stock2.as_json)
          end
        end

        context 'contest_id doesnt presence in query' do
          include_context 'auth token'

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(ContestApplicationStock.all.as_json)
          end
        end
      end
    end
  end

  path '/api/v1/contest_application_stocks/{id}/' do
    let!(:contest_application) { create :contest_application }
    let!(:stock) { create :stock }
    let!(:contest_application_stock) { create :contest_application_stock }

    delete 'delete a contest application stock' do
      tags 'ContestApplicationStock'
      parameter name: :id, in: :path, type: :integer

      response '204', 'contest application successfully deleted' do
        include_context 'auth token'

        let(:id) { contest_application_stock.id }

        run_test! do
          expect(ContestApplicationStock.where(id: id)).to_not exist
        end
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

        let(:id) { contest_application_stock.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(ContestApplicationStock.find_by(id: id).as_json)
        end
      end

      response '404', 'contest application stock not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end
end
