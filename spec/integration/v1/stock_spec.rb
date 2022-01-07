# frozen_string_literal: true

require 'swagger_helper'

describe 'Stock API', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/stocks/' do
    post 'Create a stock' do
      tags 'Stock'
      parameter name: :stock, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: %w[name]
      }

      response '201', 'stock created' do
        include_context 'auth token'
        let(:stock) { build(:stock, :exist_in_Finnhub) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(Stock.where(id: data['id'].to_i)).to exist
        end
      end

      response '400', 'stock not created' do
        context 'stock already exists' do
          include_context 'auth token'
          let!(:stock1) { create :stock }
          let(:stock) { { name: stock1.name } }

          run_test!
        end

        context 'invalid stock' do
          include_context 'auth token'
          let(:stock) { build(:stock, :with_random_name) }

          run_test! do
            expect(response.body).to include("Finnhub couldn't find symbol")
          end
        end
      end
    end

    get 'Get stocks' do
      tags 'Stock'
      let!(:stock) { create :stock }
      let!(:briefcase) { create :briefcase }

      before do
        @user = briefcase.user
        briefcase.stocks << stock
      end

      response '200', 'get all stocks' do
        auth_user

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Stock.joins(:briefcases).where(briefcases: { user: @user }).distinct.as_json)
        end
      end
    end
  end

  path '/api/v1/stocks/{id}/' do
    let!(:stock) { create :stock }
    let!(:briefcase) { create :briefcase }

    before do
      @user = briefcase.user
      briefcase.stocks << stock
    end

    delete 'delete a stock' do
      tags 'Stock'
      parameter name: :id, in: :path, type: :integer

      response '204', 'stock successfully deleted' do
        auth_user

        let(:id) { stock.id }

        run_test! do
          expect(Stock.where(id: id)).to_not exist
        end
      end

      response '404', 'Not found 404' do
        auth_user
        let(:id) { 'invalid' }

        run_test!
      end
    end

    get 'Retrieve a stock' do
      tags 'Stock'
      parameter name: :id, in: :path, type: :integer

      response '200', 'stock found' do
        include_context 'auth token'

        let(:id) { stock.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Stock.find_by(id: id).as_json)
        end
      end

      response '404', 'stock not found' do
        auth_user

        let(:id) { 'invalid' }
        run_test!
      end
    end
  end

  path '/api/v1/stocks/suggestions/' do
    get 'Get 10 stocks' do
      tags 'Stock'

      response '200', 'get 10 stocks' do
        include_context 'auth token'
        let!(:stocks) { create_list(:stock, 30, :with_random_name) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.count).to eq(Briefcase::BRIEFCASE_STOCKS_MAX_COUNT)
        end
      end
    end
  end

  path '/api/v1/stocks/name/{name}/' do
    let(:stock) { create :stock }

    get 'Retrieve a stock by name' do
      tags 'Stock'
      parameter name: :name, in: :path, type: :string

      response '200', 'stock found' do
        include_context 'auth token'
        let(:name) { stock.name }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Stock.find_by(name: name).as_json)
        end
      end

      response '404', 'stock not found' do
        include_context 'auth token'
        let(:name) { 'invalid' }

        run_test!
      end
    end
  end
end
