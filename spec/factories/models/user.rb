# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 3..20).add_discriminator }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 6) }
    factory :user_with_points do
      email_validated { true }
      preferred_lang { 'ru_RU' }
      coins { Faker::Number.within(range: 1..10 ** 10) }
      fantasy_points { Faker::Number.within(range: 1..10 ** 10) }
    end

    trait :with_few_coins do
      coins { Faker::Number.within(range: 1..5) }
    end

    trait :with_many_coins do
      coins { Faker::Number.within(range: 1000..2000) }
    end
  end
end
