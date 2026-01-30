require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
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

    # Autoload lib and app/contracts (each file defines one constant, e.g. AuthenticationContract)
    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app', 'contracts')
    config.eager_load_paths << Rails.root.join('lib')
    config.eager_load_paths << Rails.root.join('app', 'contracts')

    # Sidekiq as ActiveJob adapter
    config.active_job.queue_adapter = :sidekiq

    # CORS is configured in config/initializers/cors.rb

    # Mailer default from address
    config.action_mailer.default_options = { from: 'admin@example.com' }

    # Timezone
    config.time_zone = 'UTC'
    config.active_record.default_timezone = :utc
  end
end
