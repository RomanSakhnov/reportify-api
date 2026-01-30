require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Ensure secret_key_base is always a String (required for production)
  config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', '').to_s
  if config.secret_key_base.empty?
    raise ArgumentError, 'SECRET_KEY_BASE environment variable must be set to a non-empty string'
  end

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.force_ssl = false
  config.log_level = :info
  config.log_tags = [:request_id]
  config.action_controller.perform_caching = true

  # Use memory store to avoid Redis 5 / connection_pool compatibility issue with redis_cache_store.
  # Redis is still used for Sidekiq. Switch to :redis_cache_store when using Redis 4.x if you need shared cache.
  config.cache_store = :memory_store, { size: 64.megabytes }

  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []
  config.log_formatter = ::Logger::Formatter.new

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false

  # Action Mailer: use SMTP or another delivery method (set in env)
  config.action_mailer.delivery_method = ENV.fetch('MAILER_DELIVERY_METHOD', :smtp).to_sym
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    address: ENV.fetch('SMTP_ADDRESS', 'localhost'),
    port: ENV.fetch('SMTP_PORT', 587).to_i,
    domain: ENV.fetch('SMTP_DOMAIN', 'example.com'),
    user_name: ENV['SMTP_USER_NAME'],
    password: ENV['SMTP_PASSWORD'],
    authentication: ENV.fetch('SMTP_AUTHENTICATION', 'plain'),
    enable_starttls_auto: true
  }.compact
end
