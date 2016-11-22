class Scraped
  class Response
    class Decorator
      def initialize(response:, config: {})
        @response = response
        @config = config.to_h
      end

      def decorated_response
        Response.new(url: url, body: body, headers: headers, status: status)
      end

      def url
        response.url
      end

      def body
        response.body
      end

      def headers
        response.headers
      end

      def status
        response.status
      end

      private

      attr_reader :response, :config
    end
  end
end
