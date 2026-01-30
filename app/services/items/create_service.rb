# Service for creating new items with validation
module Items
  class CreateService < ApplicationService
    def initialize(params)
      @params = params
    end

    def call
      validated = yield validate_params
      item = yield create_item(validated)

      success(item)
    end

    private

    def validate_params
      result = ItemContract.new.call(@params)

      if result.success?
        success(result.to_h)
      else
        failure(errors: result.errors.to_h)
      end
    end

    def create_item(attributes)
      item = Item.new(attributes)

      if item.save
        success(item)
      else
        failure(errors: item.errors.messages)
      end
    end
  end
end
