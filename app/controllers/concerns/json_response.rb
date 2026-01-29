# Concern for standardized JSON responses
# Provides helper methods for rendering success and error responses
module JsonResponse
  extend ActiveSupport::Concern

  def render_success(data = nil, status = :ok, meta = {})
    response = { success: true }
    response[:data] = data if data.present?
    response[:meta] = meta if meta.present?

    render json: response, status: status
  end

  def render_error(message, status = :unprocessable_entity, errors = nil)
    response = {
      success: false,
      message: message
    }
    response[:errors] = errors if errors.present?

    render json: response, status: status
  end

  def render_service_result(result, success_status: :ok)
    case result
    when Dry::Monads::Success
      render_success(result.value!, success_status)
    when Dry::Monads::Failure
      error_data = result.failure
      message = error_data[:message] || 'Operation failed'
      errors = error_data[:errors]
      render_error(message, :unprocessable_entity, errors)
    end
  end
end
