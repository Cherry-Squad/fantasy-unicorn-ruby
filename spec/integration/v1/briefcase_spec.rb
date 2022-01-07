# frozen_string_literal: true

require 'swagger_helper'

describe 'Briefcase API', swagger_doc: 'v1/swagger.yaml' do
  path '/api/v1/briefcases/' do
    post 'Create a briefcase' do
      tags 'Briefcase'

      response '201', 'briefcase created' do
        include_context 'auth token'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(Briefcase.where(id: data['id'].to_i)).to exist
        end
      end
    end

    get 'Get all briefcases' do
      tags 'Briefcase'

      let(:user_obj) { create :user }
      before do
        @user = user_obj
      end

      let!(:briefcase) { create :briefcase, user_id: user_obj.id }

      response '200', 'get all briefcases for current user' do
        auth_user

        run_test! do |response|
          body = JSON.parse(response.body).map(&:as_json)
          expect(body).to include(briefcase.as_json)
        end
      end
    end
  end

  path '/api/v1/briefcases/{id}/' do
    let(:briefcase) { create :briefcase }

    before do
      @user = briefcase.user
    end

    delete 'delete a briefcase' do
      tags 'Briefcase'
      parameter name: :id, in: :path, type: :integer, required: true

      response '204', 'briefcase successfully deleted' do
        auth_user

        let(:id) { briefcase.id }

        run_test! do
          expect(Briefcase.where(id: id)).to_not exist
        end
      end

      response '404', 'Not found 404' do
        auth_user
        let(:id) { 'invalid' }

        run_test!
      end
    end

    get 'Retrieve a briefcase' do
      tags 'Briefcase'
      parameter name: :id, in: :path, type: :integer

      response '200', 'briefcase connected with current user found' do
        auth_user

        let(:id) { briefcase.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Briefcase.find_by(id: id).as_json)
        end
      end

      response '404', 'briefcase not found' do
        auth_user

        let(:id) { 'invalid' }
        run_test!
      end
    end

    patch 'Update a briefcase' do
      let!(:stock) { create :stock }

      tags 'Briefcase'
      parameter name: :id, in: :path, type: :integer, required: true

      response '404', 'briefcase not found' do
        auth_user

        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            stock_id: { type: :integer },
            add: { type: :boolean }
          }
        }

        let(:id) { 'invalid' }
        let(:data) { { stock_id: stock.id, add: true } }
        run_test!
      end

      response '201', 'briefcase updated' do
        auth_user

        context 'add stock to briefcase' do
          parameter name: :data, in: :body, schema: {
            type: :object,
            properties: {
              stock_id: { type: :integer },
              add: { type: :boolean }
            }
          }

          let(:data) { { stock_id: stock.id, add: true } }
          let(:id) { briefcase.id }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(Briefcase.find_by(id: data['id']).stocks).to include(stock)
          end
        end

        context 'delete stock from briefcase' do
          parameter name: :briefcase, in: :body, schema: {
            type: :object,
            properties: {
              stock_id: { type: :integer },
              add: { type: :boolean }
            }
          }

          let(:id) { briefcase.id }
          let(:data) { { stock_id: stock.id, add: false } }
          before do
            briefcase.stocks << stock
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(Briefcase.find_by(id: data['id']).stocks).to_not include(stock)
          end
        end
      end

      response '400', 'stock not found' do
        auth_user

        parameter name: :data, in: :body, schema: {
          type: :object,
          properties: {
            stock_id: { type: :integer },
            add: { type: :boolean }
          }
        }

        let(:id) { briefcase.id }
        let(:data) { { stock_id: 'invalid', add: true } }
        run_test!
      end
    end
  end

  path '/api/v1/briefcases/{id}/stocks/' do
    let(:briefcase_obj) { create(:briefcase, :with_stocks) }
    let(:id) { briefcase_obj.id }

    get 'Get stocks by briefcase id' do
      tags 'Briefcase'
      parameter name: :id, in: :path, type: :integer

      response '200', 'stocks in briefcase' do
        include_context 'auth token'
        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Briefcase.find(id).stocks.as_json)
        end
      end

      response '404', 'not found' do
        include_context 'auth token'
        let(:id) { 'invalid' }

        run_test!
      end
    end
  end
end
