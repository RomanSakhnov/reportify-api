# JWT token encoding and decoding utility
# This class handles JWT token generation and verification using the jwt gem
class JwtEncoder
  SECRET_KEY = ENV.fetch('JWT_SECRET_KEY', Rails.application.credentials.secret_key_base)
  ALGORITHM = 'HS256'.freeze
  EXPIRATION_TIME = 24.hours.to_i

  # Encode payload into JWT token
  # @param payload [Hash] Data to encode
  # @param exp [Integer] Expiration time in seconds (optional)
  # @return [String] JWT token
  def self.encode(payload, exp = EXPIRATION_TIME)
    payload[:exp] = Time.now.to_i + exp
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  # Decode JWT token
  # @param token [String] JWT token to decode
  # @return [Hash, nil] Decoded payload or nil if invalid
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: ALGORITHM)
    decoded[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
