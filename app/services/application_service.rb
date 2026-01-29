# Base service class for all service objects
# Services follow the command pattern and return a Result monad (Success or Failure)
# This demonstrates the use of dry-monads for functional error handling
class ApplicationService
  include Dry::Monads[:result, :do]

  # Call the service and return a Result monad
  # @return [Dry::Monads::Result]
  def self.call(...)
    new(...).call
  end

  # Instance method to be implemented by subclasses
  def call
    raise NotImplementedError, "#{self.class} must implement #call"
  end

  protected

  # Helper to create a success result
  def success(value = nil)
    Success(value)
  end

  # Helper to create a failure result
  def failure(error)
    Failure(error)
  end
end
