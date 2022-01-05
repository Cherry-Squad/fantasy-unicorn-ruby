# frozen_string_literal: true

require 'swagger_helper'

describe 'Stock API', swagger_doc: 'v1/swagger.yaml' do
  let(:briefcase_obj) { build(:briefcase) }
  let(:expiring_at) { Time.now.utc + 604800 }
  let(:briefcase) { { expiring_at: expiring_at} }
  let(:stock_obj) { build(:stock) }
  let(:name) { stock_obj.name }
  let(:stock) { { name: name} }

  path '/api/v1/stocks/' do
    post 'Create a stock' do
      tags 'Stock'

      response '201', 'stock created' do
        include_context 'auth token'
        parameter name: :stock, in: :body, schema: {
          type: :object,
          properties: {
            name: { type: :string },
          },
          required: %w[name]
        }

        run_test!
      end

    end

    get 'Get stocks' do
      tags 'Stock'
      let(:stock) { create :stock }
      let(:briefcase) { create :briefcase }
      let(:user_obj) { briefcase.user }
      before do
        @user = briefcase.user
        briefcase.stocks << stock
      end

      response '200', 'get all stocks' do
        auth_user

        run_test!
      end
    end
  end

  path '/api/v1/stocks/{id}/' do
    let(:stock) { create :stock }
    let(:briefcase) { create :briefcase }
    let(:user_obj) { briefcase.user }
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
        run_test!
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
        auth_user

        let(:id) { stock.id }
        run_test!
      end

      response '404', 'stock not found' do
        auth_user

        let(:id) { 'invalid' }
        run_test!
      end
    end

  end

end

