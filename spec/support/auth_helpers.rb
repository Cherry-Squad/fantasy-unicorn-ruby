# frozen_string_literal: true

RSpec.shared_context 'auth token' do
  let(:user_obj) { create(:user) }
  let(:authHeaders) { user_obj.create_new_auth_token }
  let(:"Access-Token") { authHeaders['access-token'] }
  let(:Client) { authHeaders['client'] }
  let(:UID) { authHeaders['uid'] }
end
