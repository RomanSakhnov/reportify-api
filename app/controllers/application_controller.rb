class ApplicationController < ActionController::API
  include JsonResponse

  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found(_exception)
    render_error('Record not found', :not_found)
  end

  def parameter_missing(exception)
    render_error(exception.message, :bad_request)
  end

  def authorize_admin!
    return if current_user&.admin?

    render_error('Admin access required', :forbidden)
  end
end
