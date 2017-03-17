module Scraped
  class Request
    class Strategy
      class NotImplementedError < StandardError; end

      def initialize(url:, headers: {}, config: {})
        @url = url
        @headers = headers
        @config = config.to_h
      end

      def response
        raise NotImplementedError, "No #{self.class}#response method found"
      end

      private

      attr_reader :url, :headers, :config
    end
  end
end
