# JWT Authentication concern for API controllers
# Provides authentication helpers and before_action filters
module JwtAuthentication
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  # Authenticate user from JWT token in Authorization header
  # Call this as a before_action in controllers that require authentication
  def authenticate_user!
    token = extract_token

    return render_error('Missing authorization token', :unauthorized) unless token

    payload = JwtEncoder.decode(token)

    return render_error('Invalid or expired token', :unauthorized) unless payload

    @current_user = User.find_by(id: payload['user_id'])

    return if @current_user&.active?

    render_error('User not found or inactive', :unauthorized)
  end

  # Check if current user is an admin
  def authorize_admin!
    return if current_user&.admin?

    render_error('Admin access required', :forbidden)
  end

  private

  # Extract JWT token from Authorization header
  # Expected format: "Bearer <token>"
  def extract_token
    header = request.headers['Authorization']
    return nil unless header

    header.split(' ').last if header.start_with?('Bearer ')
  end
end
