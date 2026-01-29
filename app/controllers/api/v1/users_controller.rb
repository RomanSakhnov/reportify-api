module Api
  module V1
    class UsersController < ApplicationController
      before_action :set_user, only: %i[show update destroy]
      before_action :authorize_admin!, only: %i[create destroy]

      # GET /api/v1/users
      def index
        users = User.all.order(created_at: :desc)

        render_success(
          users.map { |user| user_json(user) },
          :ok,
          { total: users.count }
        )
      end

      # GET /api/v1/users/:id
      def show
        render_success(user_json(@user))
      end

      # POST /api/v1/users
      def create
        result = Users::CreateService.call(user_params)
        render_service_result(result, success_status: :created)
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        # Only admins or the user themselves can update
        return render_error('Unauthorized', :forbidden) unless current_user.admin? || current_user.id == @user.id

        result = Users::UpdateService.call(@user, user_params)
        render_service_result(result)
      end

      # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        render_success({ message: 'User deleted successfully' })
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.permit(:name, :email, :password, :role, :active)
      end

      def user_json(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          active: user.active,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
