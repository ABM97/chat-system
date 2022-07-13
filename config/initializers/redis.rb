require "redis"
require 'redis-namespace'
require 'connection_pool'

require File.join(Rails.root, 'app/models/chat')

pool_size = 10

$redis = ConnectionPool.new(size: pool_size) do
  Redis::Namespace.new(
    :chat_system,
    redis: Redis.new(url: Rails.configuration.redis_url)
  )
end

