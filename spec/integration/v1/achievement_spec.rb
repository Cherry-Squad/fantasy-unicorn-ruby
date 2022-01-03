# frozen_string_literal: true
# # frozen_string_literal: true
#
# require 'swagger_helper'
#
# describe 'Auth API', swagger_doc: 'v1/swagger.yaml' do
#   let(:briefcase_obj) { build(:briefcase) }
#   let(:expiring_at) { briefcase_obj.expiring_at }
#   let(:briefcase) { { expiring_at: expiring_at} }
#
#   path '/api/v1/briefcase/' do
#     post 'Create a briefcase' do
#       tags 'Briefcase'
#       parameter name: :briefcase, in: :body, schema: {
#         type: :object,
#         properties: {
#           expiring_at: { type: :string },
#         },
#         required: %w[expiring_at]
#       }
#
#       response '201', 'briefcase created' do
#         include_context 'auth token'
#
#         run_test! do
#           expect(Briefcase.count).to eq(1)
#         end
#       end
#
#       response '400', 'Bad request' do
#         include_context 'auth token'
#         let(:expiring_at) { Faker::Internet.username }
#
#         run_test! do
#           expect(response.body).to include("Bad request ( invalid data )")
#         end
#       end
#
#     end
#   end
#   path '/api/v1/briefcase/id/' do
#     delete 'delete a briefcase' do
#       tags 'Briefcase'
#       parameter name: :briefcase, in: , schema: {
#         type: :object,
#         properties: {
#           id: { type: :integer },
#         },
#       }
#
#       response '204', 'briefcase successfully deleted' do
#         include_context 'auth token'
#
#         run_test! do
#           expect(Briefcase.count).to eq(0)
#         end
#       end
#
#       response '404', 'Not found 404' do
#         include_context 'auth token'
#
#         run_test! do
#           expect(response.body).to include({status: "Not found 404"})
#         end
#       end
#     end
#   end
# end
