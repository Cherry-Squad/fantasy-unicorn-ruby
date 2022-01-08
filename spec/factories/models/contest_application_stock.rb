# frozen_string_literal: true

FactoryBot.define do
  factory :contest_application_stock do
    contest_application
    stock

    multiplier { 1.0 }
    direction_up { Faker::Boolean.boolean }

    trait :with_variable_multiplier do
      multiplier { Faker::Number.decimal(l_digits: 1, r_digits: 2) + 0.01 }
    end

    reg_price { Faker::Number.between(from: 0.5, to: 5000.0) }

    trait :with_final_price do
      contest_application { association :contest_application, :with_results }
      final_price { Faker::Number.between(from: 0.5, to: 5000.0) }
    end
  end
end
