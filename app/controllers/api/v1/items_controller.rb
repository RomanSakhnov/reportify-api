module Api
  module V1
    class ItemsController < ApplicationController
      before_action :set_item, only: %i[show update destroy]
      before_action :authorize_item_owner!, only: %i[update destroy]

      # GET /api/v1/items
      def index
        items = Item.includes(:user).order(created_at: :desc)

        # Filter by category if provided
        items = items.by_category(params[:category]) if params[:category].present?

        # Filter by active status
        items = items.active if params[:active] == 'true'

        render_success(
          items.map { |item| item_json(item) },
          :ok,
          { total: items.count }
        )
      end

      # GET /api/v1/items/:id
      def show
        render_success(item_json(@item))
      end

      # POST /api/v1/items
      def create
        result = Items::CreateService.call(
          item_params.merge(user_id: current_user.id)
        )
        render_service_result(result, success_status: :created)
      end

      # PATCH/PUT /api/v1/items/:id
      def update
        result = Items::UpdateService.call(@item, item_params)
        render_service_result(result)
      end

      # DELETE /api/v1/items/:id
      def destroy
        @item.destroy
        render_success({ message: 'Item deleted successfully' })
      end

      private

      def set_item
        @item = Item.includes(:user).find(params[:id])
      end

      def authorize_item_owner!
        return if current_user.admin? || @item.user_id == current_user.id

        render_error('Unauthorized', :forbidden)
      end

      def item_params
        params.permit(:name, :description, :category, :price, :quantity, :active)
      end

      def item_json(item)
        {
          id: item.id,
          name: item.name,
          description: item.description,
          category: item.category,
          price: item.price&.to_f,
          quantity: item.quantity,
          active: item.active,
          user: {
            id: item.user.id,
            name: item.user.name,
            email: item.user.email
          },
          created_at: item.created_at,
          updated_at: item.updated_at
        }
      end
    end
  end
end
