module Api
  module V1
    class ReportsController < ApplicationController
      # GET /api/v1/reports/dashboard
      # Returns aggregated dashboard data for charts and metrics
      def dashboard
        result = Reports::GenerateDashboardService.call
        render_service_result(result)
      end

      # GET /api/v1/reports/metrics
      # Returns time-series metrics data from report_data table
      def metrics
        days = params[:days]&.to_i || 30
        start_date = days.days.ago.to_date

        report_data = ReportDatum.where('date >= ?', start_date)
                                 .order(date: :asc)

        grouped_data = report_data.group_by(&:report_type)

        result = grouped_data.transform_values do |records|
          records.map do |record|
            {
              date: record.date,
              data: record.data
            }
          end
        end

        render_success(result)
      end

      # GET /api/v1/reports/trends
      # Returns trend analysis data
      def trends
        # Calculate various trends
        trends = {
          user_trend: calculate_trend(User, 30),
          item_trend: calculate_trend(Item, 30),
          categories: Item.group(:category).count,
          top_users: top_users_by_items
        }

        render_success(trends)
      end

      private

      def calculate_trend(model, days)
        current_count = model.where('created_at >= ?', days.days.ago).count
        previous_count = model.where('created_at >= ? AND created_at < ?',
                                     (days * 2).days.ago, days.days.ago).count

        change = previous_count.zero? ? 0 : ((current_count - previous_count) / previous_count.to_f * 100).round(2)

        {
          current: current_count,
          previous: previous_count,
          change_percentage: change
        }
      end

      def top_users_by_items
        User.joins(:items)
            .select('users.*, COUNT(items.id) as items_count')
            .group('users.id')
            .order('items_count DESC')
            .limit(5)
            .map do |user|
              {
                id: user.id,
                name: user.name,
                email: user.email,
                items_count: user.items_count
              }
            end
      end
    end
  end
end
