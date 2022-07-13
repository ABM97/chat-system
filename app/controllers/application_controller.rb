require 'securerandom'
require 'redis_service'

class ApplicationController < ActionController::API
  include ExceptionHandler
end
