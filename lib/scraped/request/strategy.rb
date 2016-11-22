class Scraped
  class Request
    class Strategy
      class NotImplementedError < StandardError; end

      def initialize(url:, config:)
        @url = url
        @config = config
      end

      def response
        raise NotImplementedError, "No #{self.class}#response method found"
      end

      private

      attr_reader :url, :config
    end
  end
end