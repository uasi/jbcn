# frozen_string_literal: true

module Jbcn
  class Client
    CLOCK_ENDPOINT = "https://ssl.jobcan.jp/employee/index/adit"

    def authenticate(credentials)
      if (h = credentials).is_a?(Hash)
        if (code = h[:code])
          credentials = CodeCredentials.new(code)
        elsif ((client_id = h[:client_id]) &&
               (username = h[:username]) &&
               (password = h[:password]))
          credentials = UserCredentials.new(client_id: client_id, username: username, password: password)
        else
          fail(ArgumentError.new("missing keyword: either [code] or [client_id, email, password]"))
        end
      end
      @token = credentials.authenticate(faraday)
    end

    def clock(in_out, group_id:, note: "", night_shift: false)
      unless @token
        fail(RuntimeError, "not authenticated")
      end
      unless [:in, :out].include?(in_out)
        fail(ArgumentError.new("expected :in or :out"))
      end

      params = build_params(in_out, group_id.to_s, note.to_s, !!night_shift)
      response = faraday.post(CLOCK_ENDPOINT, params) rescue fail(ClockError)

      # Jobcan would normally return responses with status code 200
      # regardless of whether the request was success or not,
      # so status != 200 is really an unexpected condition.
      unless response.status == 200
        fail(ClockError.new(response: response))
      end

      result = JSON.parse(response.body) rescue
        fail(ClockResponseParseError.new(response: response))

      if result["errors"]
        if result["errors"]["aditCount"] == "duplicate"
          fail(ClockRequestDuplicateError.new(response: response, result: result))
        end
        fail(ClockError.new(response: response, result: result))
      end

      result
    end

    private

    def build_params(in_out, group_id, note, night_shift)
      {
        adit_item: in_out == :in ? "work_start" : "work_end",
        adit_group_id: group_id,
        notice: note,
        is_yakin: night_shift ? "1" : "0",
        token: @token,
      }
    end

    def faraday
      @faraday ||= Faraday.new do |builder|
        builder.request :url_encoded
        builder.use FaradayMiddleware::FollowRedirects
        builder.use :cookie_jar
        builder.adapter Faraday.default_adapter
      end
    end
  end
end
