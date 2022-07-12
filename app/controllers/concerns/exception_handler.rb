module ExceptionHandler
  extend ActiveSupport::Concern

  ERRORS = {
    'ActiveRecord::RecordNotFound' => 'Errors::NotFound',
    'ActiveRecord::RecordInvalid' => 'Errors::UnprocessableEntity',
  }

  included do
    rescue_from(StandardError, with: lambda { |e| handle_error(e) })
  end

  private

  def handle_error(e)
    mapped = map_error(e)
    mapped ||= Errors::StandardError.new(detail: e.message)
    logger.error e.message
    logger.error e.backtrace.join("\n")
    render_error(mapped)
  end

  def map_error(e)
    error_klass = e.class.name
    e if ERRORS.values.include?(error_klass)
  end

  def render_error(error)
    render json: ErrorSerializer.new(error), status: error.status
  end

end