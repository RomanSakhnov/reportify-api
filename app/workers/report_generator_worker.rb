# Background worker for generating report data
# This worker periodically generates random report data using Faker
# Schedule this worker to run daily via cron or Sidekiq scheduler
class ReportGeneratorWorker
  include Sidekiq::Worker

  sidekiq_options queue: :default, retry: 3

  def perform(date = nil)
    target_date = date ? Date.parse(date) : Date.today

    Rails.logger.info "Generating reports for #{target_date}"

    generate_daily_metrics(target_date)
    generate_user_activity(target_date)
    generate_item_sales(target_date)

    Rails.logger.info "Reports generated successfully for #{target_date}"
  end

  private

  # Generate daily metrics report with random data
  def generate_daily_metrics(date)
    data = {
      page_views: Faker::Number.between(from: 1000, to: 5000),
      unique_visitors: Faker::Number.between(from: 500, to: 2000),
      avg_session_duration: Faker::Number.between(from: 120, to: 600),
      bounce_rate: Faker::Number.decimal(l_digits: 2, r_digits: 2).to_f,
      conversion_rate: Faker::Number.decimal(l_digits: 1, r_digits: 2).to_f
    }

    ReportDatum.find_or_create_by(report_type: 'daily_metrics', date: date) do |record|
      record.data = data
      record.metadata = { generated_at: Time.current }
    end
  end

  # Generate user activity report
  def generate_user_activity(date)
    data = {
      new_users: Faker::Number.between(from: 5, to: 50),
      active_users: Faker::Number.between(from: 100, to: 500),
      user_sessions: Faker::Number.between(from: 200, to: 1000),
      avg_actions_per_user: Faker::Number.between(from: 5, to: 25)
    }

    ReportDatum.find_or_create_by(report_type: 'user_activity', date: date) do |record|
      record.data = data
      record.metadata = { generated_at: Time.current }
    end
  end

  # Generate item sales report
  def generate_item_sales(date)
    categories = Item::CATEGORIES

    sales_by_category = categories.each_with_object({}) do |category, hash|
      hash[category] = {
        units_sold: Faker::Number.between(from: 10, to: 100),
        revenue: Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f
      }
    end

    data = {
      total_sales: Faker::Number.between(from: 100, to: 500),
      total_revenue: Faker::Number.decimal(l_digits: 5, r_digits: 2).to_f,
      avg_order_value: Faker::Number.decimal(l_digits: 3, r_digits: 2).to_f,
      by_category: sales_by_category
    }

    ReportDatum.find_or_create_by(report_type: 'item_sales', date: date) do |record|
      record.data = data
      record.metadata = { generated_at: Time.current }
    end
  end
end
