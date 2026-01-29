class Item < ApplicationRecord
  belongs_to :user

  # Validations
  validates :name, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }

  # Categories
  CATEGORIES = %w[electronics books clothing food tools other].freeze

  def self.categories
    CATEGORIES
  end
end
