# frozen_string_literal: true

FactoryBot.define do
  factory :contest_application do
    contest
    user

    trait :with_results do
      transient do
        number_of_participants { Faker::Number.within(range: 10..40) }
      end

      contest { association :contest, :finished }

      final_position { Faker::Number.within(range: 1..number_of_participants) }
      coins_delta { Faker::Number.within(range: -10 ** 10..10 ** 10) }
      fantasy_points_delta { Faker::Number.within(range: -10 ** 10..10 ** 10) }
    end
  end
end
