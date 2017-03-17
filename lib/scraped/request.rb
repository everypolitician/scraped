require 'scraped/request/strategy/live_request'
require 'scraped/response'

module Scraped
  class Request
    def initialize(url:, headers: {}, strategies: [Strategy::LiveRequest])
      @url = url
      @headers = headers
      @strategies = strategies
    end

    def response(decorators: [])
      abort "Failed to fetch #{url}" if first_successful_response.nil?
      response = Response.new(first_successful_response.merge(url: url))
      ResponseDecorator.new(response: response, decorators: decorators).response
    end

    private

    attr_reader :url, :headers, :strategies

    def first_successful_response
      @first_successful_response ||=
        strategies.lazy.map do |strategy_config|
          unless strategy_config.respond_to?(:delete)
            strategy_config = { strategy: strategy_config }
          end
          strategy_class = strategy_config.delete(:strategy)
          strategy_class.new(url: url, headers: headers, config: strategy_config).response
        end.reject(&:nil?).first
    end
  end
end
