# Service for generating dashboard report data
# Aggregates data from various models for visualization
module Reports
  class GenerateDashboardService < ApplicationService
    def call
      success(
        summary: summary_stats,
        user_growth: user_growth_data,
        item_distribution: item_distribution_data,
        recent_activity: recent_activity_data
      )
    end

    private

    def summary_stats
      {
        total_users: User.count,
        active_users: User.active.count,
        total_items: Item.count,
        active_items: Item.active.count,
        total_value: Item.sum('price * quantity').to_f.round(2)
      }
    end

    def user_growth_data
      # Last 30 days of user registrations
      users = User.where('created_at >= ?', 30.days.ago)

      # Group by date manually
      data = users.group_by { |u| u.created_at.to_date }
                  .transform_values(&:count)

      format_time_series(data)
    end

    def item_distribution_data
      # Items by category
      Item.group(:category).count
    end

    def recent_activity_data
      {
        recent_users: User.order(created_at: :desc).limit(5).pluck(:name, :email, :created_at),
        recent_items: Item.includes(:user).order(created_at: :desc).limit(5).map do |item|
          {
            id: item.id,
            name: item.name,
            category: item.category,
            owner: item.user.name,
            created_at: item.created_at
          }
        end
      }
    end

    def format_time_series(data)
      data.transform_keys { |date| date.is_a?(Date) ? date.strftime('%Y-%m-%d') : date.to_s }
    end
  end
end
