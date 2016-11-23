require 'scraped/request/strategy/live_request'
require 'scraped/response'

class Scraped
  class Request
    def initialize(url:, strategies: [Strategy::LiveRequest])
      @url = url
      @strategies = strategies
    end

    def response(decorators: [])
      abort "Failed to fetch #{url}" if first_successful_response.nil?
      response = Response.new(first_successful_response.merge(url: url))
      decorators.reduce(response) do |r, decorator_config|
        unless decorator_config.respond_to?(:delete)
          decorator_config = { decorator: decorator_config }
        end
        decorator_class = decorator_config.delete(:decorator)
        decorator_class.new(response: r, config: decorator_config)
                       .decorated_response
      end
    end

    private

    attr_reader :url, :strategies

    def first_successful_response
      @first_successful_response ||=
        strategies.lazy.map { |r| r.new(url: url, config: c).response }
                  .reject(&:nil?).first
    end
  end
end
