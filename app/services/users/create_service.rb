# Service for creating new users with validation
# Demonstrates service object pattern with dry-validation
module Users
  class CreateService < ApplicationService
    def initialize(params)
      @params = params
    end

    def call
      validated = yield validate_params
      user = yield create_user(validated)

      success(user)
    end

    private

    def validate_params
      result = Contracts::UserContract.new.call(@params)

      if result.success?
        success(result.to_h)
      else
        failure(errors: result.errors.to_h)
      end
    end

    def create_user(attributes)
      user = User.new(attributes)

      if user.save
        success(user)
      else
        failure(errors: user.errors.messages)
      end
    end
  end
end
