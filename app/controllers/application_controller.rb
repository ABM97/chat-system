require 'securerandom'
require 'redis_service'
require 'rabbitmq_producer'

class ApplicationController < ActionController::API
  include ExceptionHandler
end
