require 'scraped/request/strategy/live_request'
require 'scraped/response'

class Scraped
  class Request
    def initialize(url:, readers: [Strategy::LiveRequest])
      @url = url
      @readers = readers
    end

    def response(response_decorators = [])
      abort "Failed to fetch #{url}" if first_successful_response.nil?
      response = Response.new(first_successful_response.merge(url: url))
      response_decorators.reduce(response) do |r, decorator|
        decorator_class, config = decorator
        decorator_class.new(response: r, config: config).decorated_response
      end
    end

    private

    def first_successful_response
      @first_successful_response ||=
        readers.lazy.map { |r, c| r.new(url: url, config: c).response }
               .reject(&:nil?).first
    end

    attr_reader :url, :readers
  end
end
