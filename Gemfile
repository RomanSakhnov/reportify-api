source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.2.0'

# Core Rails
gem 'pg', '~> 1.5'
gem 'puma', '~> 6.0'
gem 'rails', '~> 7.1.0'

# API
gem 'jbuilder'
gem 'rack-cors'

# Authentication
gem 'devise', '~> 4.9'
gem 'devise-jwt', '~> 0.11'

# Background Jobs
gem 'redis', '~> 5.0'
gem 'sidekiq', '~> 7.0'

# dry-rb gems for business logic
gem 'dry-monads', '~> 1.6'
gem 'dry-struct', '~> 1.6'
gem 'dry-types', '~> 1.7'
gem 'dry-validation', '~> 1.10'

# Data generation
gem 'faker', '~> 3.2'

# Reduces boot times through caching
gem 'bootsnap', require: false

# Load environment variables from .env file
gem 'dotenv-rails'

group :development, :test do
  gem 'factory_bot_rails', '~> 6.4'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 6.1'
end

group :development do
  gem 'kamal', '~> 1.0'
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test do
  gem 'database_cleaner-active_record'
  gem 'shoulda-matchers', '~> 6.0'
  gem 'simplecov', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
