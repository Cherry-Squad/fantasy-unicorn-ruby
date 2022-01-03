# frozen_string_literal: true

require 'swagger_helper'

describe 'Auth API', swagger_doc: 'v1/swagger.yaml' do
  let(:briefcase_obj) { build(:briefcase) }
  let(:expiring_at) { briefcase_obj.expiring_at }
  let(:briefcase) { { expiring_at: expiring_at} }

  path '/api/v1/briefcase/' do
    post 'Create a briefcase' do
      tags 'Briefcase'
      parameter name: :briefcase, in: :body, schema: {
        type: :object,
        properties: {
          expiring_at: { type: :string },
        },
        required: %w[expiring_at]
      }

      response '201', 'briefcase created' do
        include_context 'auth token'

        run_test! do
          expect(Briefcase.count).to eq(1)
        end
      end

      response '400', 'Bad request' do
        include_context 'auth token'
        let(:expiring_at) { Faker::Internet.username }

        run_test! do
            expect(response.body).to include("Bad request ( invalid data )")
        end
      end

    end
  end
  path '/api/v1/briefcase/{id}/' do
    let!(:briefcase_obj) { create(:briefcase) }
    let(:id) { briefcase_obj.id }
    delete 'delete a briefcase' do
      tags 'Briefcase'
      parameter name: :id, in: :path, type: :integer, nullable: false

      response '204', 'briefcase successfully deleted' do
        include_context 'auth token'

        run_test!
      end

      response '404', 'Not found 404' do
        include_context 'auth token'
        let(:id) { 'invalid' }

        run_test!
      end
    end

    get 'Retrieve a briefcase' do
      tags 'Briefcase'
      parameter name: :id, in: :path, type: :integer

      response '200', 'briefcase found' do
        include_context 'auth token'

        schema type: :object,
               property: {
                 id: { type: :integer },
                 expiring_at: { type: :string },
                 user_id: { type: :integer },
                 created_at: { type: :string },
                 updated_at: { type: :string}
               }

        let(:id) { briefcase_obj.id }
        run_test!
      end

      response '404', 'briefcase not found' do
        include_context 'auth token'

        let(:id) { 'invalid' }
        run_test!
      end

    end
  end

end

