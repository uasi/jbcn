# frozen_string_literal: true

module Jbcn
  class Credentials
    attr_reader :token

    def authenticate(_faraday)
      fail(NotImplementedError)
    end
  end

  class CodeCredentials < Credentials
    AUTH_ENDPOINT = "https://ssl.jobcan.jp/employee?code="

    attr_reader :code

    def initialize(code)
      @code = code
    end

    def authenticate(faraday)
      response = faraday.get(AUTH_ENDPOINT + @code) rescue fail(AuthError)

      unless response.status == 200
        fail(AuthError, response: response)
      end

      token = response.body[/<input type="hidden" class="token" name="token" value="([^"]+)">/, 1]
      unless token
        fail(AuthTokenNotFoundError, response: response)
      end

      token
    end
  end

  # TODO
  #class UserCredentials < Credentials
  #end
end
