require "redis"
require 'redis-namespace'

require File.join(Rails.root, 'app/models/chat')

$redis = Redis::Namespace.new(
  :chat_system,
  redis: Redis.new(host: Rails.configuration.redis_host, port: Rails.configuration.redis_port)
)
