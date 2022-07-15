module Errors
  class StandardError < ::StandardError
    def initialize(title: nil, status: nil, detail: nil)
      @title = title || "Something went wrong"
      @detail = detail || "We encountered unexpected error, but our developers had been already notified about it"
      @status = status || 500
    end

    def to_h
      {
        status: status,
        title: title,
        detail: detail
      }
    end

    def serializable_hash
      to_h
    end

    def to_s
      to_h.to_s
    end

    attr_reader :title, :detail, :status
  end

  class NotFound < Errors::StandardError
    def initialize
      super(
        title: "Record not Found",
        status: 404,
        detail: "We could not find the object you were looking for."
      )
    end
  end

  class UnprocessableEntity < Errors::StandardError
    def initialize
      super(
        title: "Unprocessable Entity",
        status: 422,
        detail: "We could not process this object."
      )
    end
  end

  class BadRequest < Errors::StandardError
    def initialize
      super(
        title: "Bad Request",
        status: 400,
        detail: "We could not process that request."
      )
    end
  end
end