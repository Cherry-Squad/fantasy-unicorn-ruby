# frozen_string_literal: true

FactoryBot.define do
  factory :stock do
    name { Faker::Finance.ticker }

    trait :with_random_name do
      name { Faker::Lorem.characters(number: rand(3..8)) }
    end
  end
end
