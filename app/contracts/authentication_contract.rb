require 'dry/validation'

# Validates login credentials before processing
class AuthenticationContract < Dry::Validation::Contract
  params do
    required(:email).filled(:string)
    required(:password).filled(:string)
  end

  rule(:email) do
    key.failure('must be a valid email address') unless /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i.match?(value)
  end

  rule(:password) do
    key.failure('must be at least 6 characters') if value.length < 6
  end
end
