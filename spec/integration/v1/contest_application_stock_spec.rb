# frozen_string_literal: true

require 'swagger_helper'

describe 'ContestApplicationStock API', swagger_doc: 'v1/swagger.yaml' do
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
            multiplier: { type: :integer }
          },
          required: %w[multiplier stock_id contest_application_id]
        }
        let(:contest_application_stock) do
          { stock_id: stock.id, contest_application_id: contest_application.id, multiplier: multiplier }
        end

        run_test! do
          expect { create :contest_application_stock }.to change { ContestApplicationStock.count }.by(1)
        end
      end

      response '400', 'contest application stock created' do
        include_context 'auth token'
        parameter name: :contest_application_stock, in: :body, schema: {
          type: :object,
          properties: {
            stock_id: { type: :integer },
            contest_application_id: { type: :integer },
            multiplier: { type: :integer }
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
      let(:contest_application_stock) { create :contest_application_stock }
      let(:contest_application) { contest_application_stock.contest_application }
      let(:stock) { contest_application_stock.stock }

      response '200', 'get all contest application stocks if contest_id not set otherwise returns all
                       contest applications by contest_id' do

        context 'contest_id presence in query' do
          parameter name: :contest_id, in: :query, type: :integer, required: false
          include_context 'auth token'

          let(:contest_id) { contest_application_stock.contest_application.contest.id }

          before { create_list(:contest_application_stock, 2) }

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(ContestApplicationStock.joins(:contest_application).
              where(contest_applications: { contest_id: contest_id } ).as_json)
          end
        end

        context 'contest_id doesnt presence in query' do
          include_context 'auth token'

          before { create_list(:contest_application_stock, 2) }

          run_test! do |response|
            body = JSON(response.body)
            expect(body.as_json).to eq(ContestApplicationStock.all.as_json)
          end
        end

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

        run_test! do
          expect { !ContestApplicationStock.find_by(id: id).exist? }
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

        let(:id) { contest_application_stock_obj.id }

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
