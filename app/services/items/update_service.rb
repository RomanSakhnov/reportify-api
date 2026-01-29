# Service for updating existing items
module Items
  class UpdateService < ApplicationService
    def initialize(item, params)
      @item = item
      @params = params
    end

    def call
      validated = yield validate_params
      updated_item = yield update_item(validated)

      success(updated_item)
    end

    private

    def validate_params
      result = Contracts::ItemContract.new.call(@params.merge(user_id: @item.user_id))

      if result.success?
        success(result.to_h)
      else
        failure(errors: result.errors.to_h)
      end
    end

    def update_item(attributes)
      if @item.update(attributes)
        success(@item)
      else
        failure(errors: @item.errors.messages)
      end
    end
  end
end
