class Scraped
  class Processor
    def call(response)
      @response = response
      Response.new(body: body, status: status, headers: headers, url: url)
    end

    def body
      response.body
    end

    def status
      response.status
    end

    def headers
      response.headers
    end

    def url
      response.url
    end

    private

    attr_reader :response
  end
end
