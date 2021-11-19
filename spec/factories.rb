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
    username { Faker::Internet.username(specifier: 3..20).add_discriminator }
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
