# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.3'
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem 'propshaft'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '>= 2.1'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.21'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem 'kamal', require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem 'thruster', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # A Ruby static code analyzer and formatter, based on the community Ruby style guide [https://github.com/rubocop/rubocop]
  gem 'rubocop', '~> 1.78'

  # rubocop-capybara [https://rubygems.org/gems/rubocop-capybara]
  gem 'rubocop-capybara', '~> 2.22'

  # rubocop-factory_bot [https://rubygems.org/gems/rubocop-factory_bot]
  gem 'rubocop-factory_bot', '~> 2.27'

  # rubocop-rails [https://rubygems.org/gems/rubocop-rails]
  gem 'rubocop-rails', '~> 2.32'

  # rubocop-rspec [https://rubygems.org/gems/rubocop-rspec]
  gem 'rubocop-rspec', '~> 3.6'

  # rubocop-rspec_rails [https://rubygems.org/gems/rubocop-rspec_rails]
  gem 'rubocop-rspec_rails', '~> 2.31'

  # rubocop-performance [https://github.com/rubocop/rubocop-performance]
  gem 'rubocop-performance', '~> 1.25'

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  # Use RSpec for testing [https://github.com/rspec/rspec-rails]
  gem 'rspec-rails', '~> 8.0'

  # Test by simulating real user interactions [https://github.com/teamcapybara/capybara]
  gem 'capybara'

  # Use SimpleCov [https://github.com/simplecov-ruby/simplecov] for code coverage
  gem 'simplecov', require: false

  # Factory Bot replaces fixtures with Ruby objects [https://github.com/thoughtbot/factory_bot_rails]
  gem 'factory_bot_rails'

  # Simple one-liner tests for common Rails functionality [https://github.com/thoughtbot/shoulda-matchers]
  gem 'shoulda-matchers', '~> 6.0'

  # Pretty print your Ruby objects with style -- in full color and with proper indentation [https://github.com/awesome-print/awesome_print]
  gem 'awesome_print'

  # Generate realistic fake data [https://github.com/faker-ruby/faker]
  gem 'faker', '~> 3.5'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Preview email in the default browser instead of sending it [https://github.com/ryanb/letter_opener]
  gem 'letter_opener'
end
