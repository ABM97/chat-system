source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.3"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"

gem 'ulid-rails', "~> 1.0.0"

gem 'active_model_serializers', "~> 0.10.13"

gem 'will_paginate', "~> 3.3.1"

gem 'elasticsearch-model', "~> 7.2.1"

gem 'redis', "~> 4.7.1"

gem 'redis-namespace', "~> 1.8.2"

gem 'sidekiq', "~> 6.5.1"

gem 'sidekiq-cron', "~> 1.6.0"

gem 'connection_pool', "~> 2.2.5"

gem "bunny", "~> 2.19.0"

gem 'sneakers', "~> 2.12.0"

gem 'rails-healthcheck', "~> 1.4.0"

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :test do
  gem 'rspec-rails', "~> 5.1.2"
  gem 'database_cleaner-active_record', "~> 2.0.1"
end

