require 'spec_helper'
require 'database_cleaner/active_record'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|

  config.include RequestSpecHelper

  # CLean Database
  config.before(:suite) do
    DatabaseCleaner[:active_record].clean_with(:deletion)
    DatabaseCleaner[:active_record].strategy = :deletion
  end

  config.around(:each) do |example|
    DatabaseCleaner[:active_record].cleaning do
      example.run
    end
  end

  # Clean RabbitMQ
  config.before(:each) do
    channel = $rmq.create_channel
    %w[db_tasks number_generation_failures].each do |queue_name|
      channel.queue(queue_name, durable: true).purge
    end
  end

  # clean ElasticSearch
  config.before :each do
    Message.__elasticsearch__.create_index!(force: true)
    Message.__elasticsearch__.refresh_index!
  end

  # clean redis
  config.before(:each) do
    $redis.with do |connection|
      connection.scan_each do |key|
        keys = connection.hgetall(key).keys
        connection.multi do |multi|
          keys.each do |k|
            multi.hdel key, k
          end
        end
      end
    end
  end

end
