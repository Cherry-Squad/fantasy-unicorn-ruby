# frozen_string_literal: true

FactoryBot.define do
  factory :achievement do
    user
    achievement_identifier { Faker::Number.within(range: 1..10**3) }
  end

  factory :user do
    username { Faker::Internet.username }
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    factory :user_with_points do
      email_validated { true }
      preferred_lang { 'ru_RU' }
      coins { Faker::Number.within(range: 1..10**10) }
      fantasy_points { Faker::Number.within(range: 1..10**10) }
    end
  end

  factory :stock do
    name { Faker::Finance.ticker }
    robinhood_id { Faker::Internet.uuid }
  end
end
