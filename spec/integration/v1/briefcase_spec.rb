# frozen_string_literal: true

require 'swagger_helper'

describe 'Briefcase API', swagger_doc: 'v1/swagger.yaml' do
  let(:briefcase_obj) { build(:briefcase) }
  let(:expiring_at) { Time.now.utc + 604_800 }
  let(:briefcase) { { expiring_at: expiring_at } }
  let(:stock_obj) { build(:stock) }
  let(:name) { stock_obj.name }
  let(:stock) { { name: name } }

  path '/api/v1/briefcases/' do
    let(:user_obj) { briefcase.user }
    before do
      @briefcase_ = create :briefcase
      @user = @briefcase_.user
    end
    post 'Create a briefcase' do
      tags 'Briefcase'

      response '201', 'briefcase created' do
        include_context 'auth token'

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Briefcase.last.as_json)
        end
      end
    end

    get 'Get all briefcases' do
      tags 'Briefcase'

      before do
        @briefcases = create_list(:briefcase, 3)
      end

      response '200', 'get all briefcases for current user' do
        auth_user

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Briefcase.where(user: @user).as_json)
        end
      end
    end
  end
  path '/api/v1/briefcases/{id}/' do
    let(:briefcase) { create :briefcase }
    let(:user_obj) { briefcase.user }
    before do
      @user = briefcase.user
    end
    delete 'delete a briefcase' do
      tags 'Briefcase'
      parameter name: :id, in: :path, type: :integer, required: true

      response '204', 'briefcase successfully deleted' do
        auth_user

        let(:id) { briefcase.id }
        run_test!
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

        schema type: :object,
               property: {
                 id: { type: :integer },
                 expiring_at: { type: :string },
                 user_id: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string }
               }

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
      tags 'Briefcase'
      parameter name: :id, in: :path, type: :integer, required: true

      response '404', 'briefcase not found' do
        auth_user
        let(:stock) { create :stock }
        let(:stock_id) { stock.id }

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
        let(:stock) { create :stock }
        let(:stock_id) { stock.id }

        parameter name: :briefcase, in: :body, schema: {
          type: :object,
          properties: {
            stock_id: { type: :integer },
            add: { type: :boolean }
          }
        }
        let(:briefcase) { create :briefcase }
        let(:data) { { stock_id: stock.id, add: true } }
        let(:id) { briefcase.id }

        run_test! do |response|
          body = JSON(response.body)
          expect(body.as_json).to eq(Briefcase.find_by(id: id).as_json)
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
end
