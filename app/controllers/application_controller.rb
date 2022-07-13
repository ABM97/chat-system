require 'securerandom'
require 'redis_service'
require 'rabbitmq_publisher'

class ApplicationController < ActionController::API
  include ExceptionHandler
end
