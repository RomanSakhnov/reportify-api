class ReportDatum < ApplicationRecord
  # Validations
  validates :report_type, presence: true
  validates :date, presence: true
  validates :data, presence: true
  validates :report_type, uniqueness: { scope: :date }

  # Scopes
  scope :by_type, ->(type) { where(report_type: type) }
  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :recent, ->(limit = 30) { order(date: :desc).limit(limit) }

  # Report types
  REPORT_TYPES = %w[daily_metrics user_activity item_sales].freeze

  def self.report_types
    REPORT_TYPES
  end
end
