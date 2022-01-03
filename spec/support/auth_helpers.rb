# frozen_string_literal: true

def auth_user
  let(:authHeaders) { @user.create_new_auth_token }
  let(:"Access-Token") { authHeaders['access-token'] }
  let(:Client) { authHeaders['client'] }
  let(:UID) { authHeaders['uid'] }
end

RSpec.shared_context 'auth token' do
  let(:user_obj) { create(:user) }
  let(:authHeaders) { user_obj.create_new_auth_token }
  let(:"Access-Token") { authHeaders['access-token'] }
  let(:Client) { authHeaders['client'] }
  let(:UID) { authHeaders['uid'] }
end
