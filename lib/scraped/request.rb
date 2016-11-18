require 'scraped/strategy/live_request'
require 'scraped/response'

class Scraped
  class Request
    def initialize(url:, readers: [Strategy::LiveRequest.new])
      @url = url
      @readers = readers
    end

    def response(response_decorators = [])
      abort "Failed to fetch #{url}" if first_successful_response.nil?
      response = Response.new(first_successful_response.merge(url: url))
      response_decorators.reduce(response) { |r, decorator| decorator.call(r) }
    end

    private

    def first_successful_response
      @first_successful_response ||=
        readers.lazy.map { |r| r.response(url) }.reject(&:nil?).first
    end

    attr_reader :url, :readers
  end
end
