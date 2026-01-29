FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    role { 'user' }
    active { true }

    trait :admin do
      role { 'admin' }
    end

    trait :inactive do
      active { false }
    end
  end
end
