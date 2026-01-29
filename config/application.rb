require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ReportifyApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Configuration for the application, engines, and railties goes here.
    config.api_only = true

    # Autoload lib and app/contracts directories
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app', 'contracts')
    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('app', 'contracts')

    # Sidekiq as ActiveJob adapter
    config.active_job.queue_adapter = :sidekiq

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        # Allow your frontend domains
        origins 'rs-test.net',
                'www.rs-test.net',
                'reportify.rs-development.net',
                'https://rs-test.net',
                'https://www.rs-test.net',
                'https://reportify.rs-development.net',
                'http://localhost:3000', # For local development
                'http://localhost:5173'  # For Vite dev server

        resource '*',
                 headers: :any,
                 methods: %i[get post put patch delete options head],
                 credentials: true, # Allow cookies/auth headers
                 expose: ['Authorization'] # Expose Authorization header for JWT
      end
    end

    # Timezone
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
  end
end
