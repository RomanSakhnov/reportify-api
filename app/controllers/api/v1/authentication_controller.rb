module Api
  module V1
    class AuthenticationController < ApplicationController
      before_action :authenticate_user!, only: %i[logout me]

      # POST /api/v1/auth/login
      # Authenticate user and return JWT token
      def login
        result = Authentication::LoginService.call(login_params)
        render_service_result(result)
      end

      # POST /api/v1/auth/logout
      # Logout is handled client-side by removing the token
      # This endpoint is mainly for tracking or additional server-side logic
      def logout
        render_success({ message: 'Logged out successfully' })
      end

      # GET /api/v1/auth/me
      # Return current user information
      def me
        render_success({
                         id: current_user.id,
                         email: current_user.email,
                         name: current_user.name,
                         role: current_user.role
                       })
      end

      private

      def login_params
        params.permit(:email, :password)
      end
    end
  end
end
