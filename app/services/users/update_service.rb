# Service for updating existing users
module Users
  class UpdateService < ApplicationService
    def initialize(user, params)
      @user = user
      @params = params
    end

    def call
      validated = yield validate_params
      updated_user = yield update_user(validated)

      success(updated_user)
    end

    private

    def validate_params
      # Remove password from params if blank
      params_to_validate = @params.dup
      params_to_validate.delete(:password) if params_to_validate[:password].blank?

      result = UserContract.new.call(params_to_validate)

      if result.success?
        success(result.to_h)
      else
        failure(errors: result.errors.to_h)
      end
    end

    def update_user(attributes)
      if @user.update(attributes)
        success(@user)
      else
        failure(errors: @user.errors.messages)
      end
    end
  end
end
