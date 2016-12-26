# frozen_string_literal: true

module Jbcn
  class Error < StandardError
  end

  class AuthError < Error
    attr_reader :response

    def initialize(message = nil, response: nil)
      super(message || default_message)
      @response = response
    end

    private

    def default_message
      "auth failed"
    end
  end

  class AuthTokenNotFoundError < AuthError
    private

    def default_message
      "token not found (maybe jobcan's html structure has changed)"
    end
  end

  class ClockError < Error
    attr_reader :response, :result

    def initialize(message = nil, response: nil, result: nil)
      super(message || default_message)
      @response = response
      @result = result
    end

    private

    def default_message
      "request failed"
    end
  end

  class ClockResponseParseError < ClockError
    private

    def default_message
      "could not parse response"
    end
  end

  class ClockRequestDuplicateError < ClockError
    private

    def default_message
      "duplicate request"
    end
  end
end
