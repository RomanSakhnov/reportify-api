require 'dry/validation'

# User contract using dry-validation
# Validates user data for creation and updates
module Contracts
  class UserContract < Dry::Validation::Contract
    params do
      required(:name).filled(:string)
      required(:email).filled(:string)
      optional(:password).filled(:string)
      optional(:role).filled(:string)
      optional(:active).filled(:bool)
    end

    rule(:email) do
      key.failure('must be a valid email address') unless /\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i.match?(value)
    end

    rule(:password) do
      key.failure('must be at least 6 characters') if value && value.length < 6
    end

    rule(:role) do
      key.failure('must be either admin or user') if value && !%w[admin user].include?(value)
    end
  end
end
