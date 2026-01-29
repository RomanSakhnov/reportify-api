FactoryBot.define do
  factory :report_datum do
    report_type { 'daily_metrics' }
    date { Date.today }
    data { { metric_1: 100, metric_2: 200 } }
    metadata { { generated_at: Time.current } }

    trait :user_activity do
      report_type { 'user_activity' }
      data { { new_users: 10, active_users: 50 } }
    end

    trait :item_sales do
      report_type { 'item_sales' }
      data { { total_sales: 100, revenue: 1000.0 } }
    end
  end
end
