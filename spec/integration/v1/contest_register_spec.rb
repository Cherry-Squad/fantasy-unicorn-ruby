# frozen_string_literal: true

require 'swagger_helper'

describe 'Contest API', swagger_doc: 'v1/swagger.yaml' do
  Delayed::Worker.delay_jobs = false
  path '/api/v1/contests/{id}/register' do
    let!(:stock) { create :stock, name: 'AAPL' }
    let!(:briefcase) { create :briefcase }
    let!(:contest) { create :contest }

    before do
      @user = briefcase.user
      briefcase.stocks << stock
    end

    post 'Register user in contest' do
      parameter name: :id, in: :path, type: :integer
      parameter name: :items, in: :body, schema: {
        type: :object,
        properties: {
          items: {
            type: :array,
            items: {
              properties: {
                stock_id: { type: :integer },
                multiplier: { type: :integer }
              },
              required: %w[multiplier stock_id contest_application_id]
            }
          }
        }
      }
      tags 'Contest'

      response '201', 'contest application created. contest application stocks created.
        assign contest application stocks' do
        auth_user
        let(:items) do
          {
            "items": [
              { stock_id: stock.id, multiplier: 1.2, direction_up: true }
            ]
          }
        end
        let(:id) { contest.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(ContestApplicationStock.find_by(
            id: data.as_json['contest_app_stocks'][0]['id'].to_i
          ).reg_price).not_to eq(nil)
        end
      end

      response '404', 'contest not found' do
        auth_user
        let(:items) do
          {
            "items": [
              { stock_id: stock.id, multiplier: 1.2 }
            ]
          }
        end
        let(:id) { 9999999 }

        run_test!
      end
    end
  end
end
