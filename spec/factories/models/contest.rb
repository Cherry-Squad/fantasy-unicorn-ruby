# frozen_string_literal: true

FactoryBot.define do
  factory :contest do
    reg_ending_at { Faker::Date.between(from: Date.today, to: 3.days.from_now) }
    summarizing_at { Faker::Date.between(from: 4.days.from_now, to: 7.days.from_now) }
    status { Contest.statuses[:created] }
    coins_entry_fee { Faker::Number.within(range: 1..10 ** 10) }
    max_fantasy_points_threshold { Faker::Number.within(range: 1..10 ** 10) }
    use_briefcase_only { Faker::Boolean.boolean }
    direction_strategy { Contest.direction_strategies.values.sample }
    fixed_direction_up { direction_strategy == Contest.direction_strategies[:fixed] ? Faker::Boolean.boolean : nil }

    trait :with_stocks do
      transient do
        stock_count { Faker::Number.within(range: 10..40) }
      end

      stocks do
        Array.new(stock_count) do
          association :stock, :with_random_name
        end
      end
    end

    trait :with_participants do
      transient do
        number_of_participants { Faker::Number.within(range: 10..40) }
      end

      contest_applications do
        Array.new(number_of_participants) do |n|
          if status == Contest.statuses[:finished]
            association :contest_application, :with_results, contest: instance, final_position: n + 1
          else
            association :contest_application, contest: instance
          end
        end
      end
    end

    trait :finished do
      transient do
        finished { true }
      end

      status { Contest.statuses[:finished] }
    end
  end
end
