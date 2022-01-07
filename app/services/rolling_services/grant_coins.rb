# frozen_string_literal: true

module RollingServices
  # Grants the number of all user's coins if there are not enough of them
  class GrantCoins < Patterns::Service
    def initialize
      super()
      @cooldown_updating = Rails.configuration.rolling_coins[:cooldown_updating]
      @amount_of_coins = Rails.configuration.rolling_coins[:amount_of_coins]
      @treshold_coins = Rails.configuration.rolling_coins[:treshold_coins]
    end

    def call
      grant_coins

      return if Rails.env.test?

      RollingServices::GrantCoins.delay(run_at: @cooldown_updating.days.from_now, queue: 'rolling_coins').call
    end

    private

    def grant_coins
      users = User.where('coins < ?', @treshold_coins)
      users.each do |user|
        user.coins += @amount_of_coins
        user.save
      end
    end
  end
end
