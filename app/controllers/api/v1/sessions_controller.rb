module Api
  module V1
    class SessionsController < Devise::SessionsController
      skip_before_action :authenticate_user!, only: [:create], raise: false
      respond_to :json

      private

      # Custom response for successful login
      def respond_with(resource, _opts = {})
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
        }, status: :ok
      end

      # Custom response for failed login
      def respond_with_navigational(*_args)
        render json: {
          success: false,
          message: 'Invalid email or password'
        }, status: :unauthorized
      end

      # Custom response for logout
      def respond_to_on_destroy
        if request.headers['Authorization'].present?
          render json: {
            success: true,
            message: 'Logged out successfully'
          }, status: :ok
        else
          render json: {
            success: false,
            message: 'No active session'
          }, status: :unauthorized
        end
      end
    end
  end
end
