require 'dry/validation'

# Validates item data for creation and updates
class ItemContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    optional(:description).maybe(:string)
    optional(:category).maybe(:string)
    optional(:price).maybe(:decimal)
    optional(:quantity).maybe(:integer)
    optional(:active).maybe(:bool)
    required(:user_id).filled(:integer)
  end

  rule(:price) do
    key.failure('must be greater than or equal to 0') if value && value < 0
  end

  rule(:quantity) do
    key.failure('must be greater than or equal to 0') if value && value < 0
  end

  rule(:category) do
    key.failure("must be one of: #{Item::CATEGORIES.join(', ')}") if value && !Item::CATEGORIES.include?(value)
  end
end
