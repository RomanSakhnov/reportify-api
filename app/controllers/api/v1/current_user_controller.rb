module Api
  module V1
    class CurrentUserController < ApplicationController
      def show
        render json: {
          success: true,
          data: {
            id: current_user.id,
            email: current_user.email,
            name: current_user.name,
            role: current_user.role
          }
        }
      end
    end
  end
end
