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
      update_coins
      return if Rails.env.test?

      RollingServices::GrantCoins.delay(run_at: @cooldown_updating.days.from_now.beginning_of_day + 3.hours,
                                        queue: 'rolling_coins').call
    end

    private

    def update_coins
      users = User.where('coins < ?', @treshold_coins)
      users.each do |user|
        user.coins += @amount_of_coins
        user.save
      end
    end
  end
end
