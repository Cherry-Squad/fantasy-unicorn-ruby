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
end
