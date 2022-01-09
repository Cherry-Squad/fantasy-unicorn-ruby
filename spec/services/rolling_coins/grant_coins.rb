# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RollingServices::GrantCoins do
  Delayed::Worker.delay_jobs = false

  let(:amount_of_coins) { Rails.configuration.rolling_coins[:amount_of_coins] }

  context 'for poor user' do
    let!(:poor_user) { create(:user, :with_few_coins) }

    it 'increase amount of coins if user is poor' do
      RollingServices::GrantCoins.call
      expect(poor_user.coins).to eq(User.last.coins - amount_of_coins)
    end
  end

  context 'for rich user' do
    let!(:rich_user) { create(:user, :with_many_coins) }

    it 'not increase amount of coins if user is rich' do
      RollingServices::GrantCoins.call
      expect(rich_user.coins).to eq(User.last.coins)
    end
  end
end
