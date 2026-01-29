FactoryBot.define do
  factory :item do
    association :user
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.paragraph }
    category { Item::CATEGORIES.sample }
    price { Faker::Commerce.price(range: 10.0..1000.0) }
    quantity { Faker::Number.between(from: 0, to: 100) }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :electronics do
      category { 'electronics' }
    end

    trait :books do
      category { 'books' }
    end
  end
end
