module Scraped
  class Response
    attr_reader :status, :headers, :body, :url

    def initialize(body:, url:, status: 200, headers: {})
      @status = status
      @headers = headers
      @body = body
      @url = url
    end
  end
end
