# frozen_string_literal: true

FactoryBot.define do
  factory :briefcase do
    user
    expiring_at { Faker::Date.forward }

    trait :with_stocks do
      transient do
        stock_count { Faker::Number.within(range: 1..Briefcase::BRIEFCASE_STOCKS_MAX_COUNT) }
      end

      stocks do
        Array.new(stock_count) do
          association :stock, :with_random_name
        end
      end
    end
  end

  factory :achievement do
    user
    achievement_identifier { Faker::Number.within(range: 1..10 ** 3) }
  end

  factory :user do
    username { Faker::Internet.username(specifier: 3..25) }
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

    trait :with_random_name do
      name { Faker::Lorem.characters(number: rand(3..8)) }
    end
  end
end
