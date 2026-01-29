module Api
  module V1
    class RegistrationsController < Devise::RegistrationsController
      skip_before_action :authenticate_user!, only: [:create], raise: false
      respond_to :json

      private

      def respond_with(resource, _opts = {})
        if resource.persisted?
          render json: {
            success: true,
            data: {
              user: {
                id: resource.id,
                email: resource.email,
                name: resource.name,
                role: resource.role
              }
            }
          }, status: :created
        else
          render json: {
            success: false,
            errors: resource.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def sign_up_params
        params.require(:user).permit(:email, :password, :name, :role)
      end

      def account_update_params
        params.require(:user).permit(:email, :password, :name, :role, :current_password)
      end
    end
  end
end
