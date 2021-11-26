# frozen_string_literal: true

FactoryBot.define do
  factory :achievement do
    user
    achievement_identifier { Faker::Number.within(range: 1..10 ** 3) }
  end
end
