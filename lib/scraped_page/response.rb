class ScrapedPage
  class Response
    attr_reader :status, :headers, :body

    def initialize(body:, status: 200, headers: {})
      @status = status
      @headers = headers
      @body = body
    end
  end
end
