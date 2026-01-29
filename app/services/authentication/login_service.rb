# Authentication service for user login
# Demonstrates dry-monads with do notation for chaining operations
# Returns Success with token or Failure with error message
class Authentication::LoginService < ApplicationService

  

  def initialize(params)
    @params = params
  end

  def call
    validated = yield validate_params
    user = yield find_user(validated[:email])
    yield authenticate_user(user, validated[:password])
    token = generate_token(user)

    success(token: token, user: user_data(user))
  end

  private

  def validate_params
    result = Contracts::AuthenticationContract.new.call(@params)

    if result.success?
      success(result.to_h)
    else
      failure(errors: result.errors.to_h, message: 'Invalid credentials format')
    end
  end

  def find_user(email)
    user = User.find_by(email: email.downcase)

    if user
      success(user)
    else
      failure(message: 'Invalid email or password')
    end
  end

  def authenticate_user(user, password)
    if user.active? && user.authenticate(password)
      success(user)
    else
      failure(message: 'Invalid email or password')
    end
  end

  def generate_token(user)
    JwtEncoder.encode(user_id: user.id, email: user.email)
  end

  def user_data(user)
    {
      id: user.id,
      email: user.email,
      name: user.name,
      role: user.role
    }
  end
end
