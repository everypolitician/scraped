require 'scraped_page/strategy/live_request'
require 'scraped_page/response'

class ScrapedPage
  class Request
    def initialize(url:, readers: [Strategy::LiveRequest.new])
      @url = url
      @readers = readers
    end

    def response(processors = [])
      abort "Failed to fetch #{url}" if first_successful_response.nil?
      response = Response.new(first_successful_response.merge(url: url))
      processors.reduce(response) { |r, handler| handler.call(r) }
      response
    end

    private

    def first_successful_response
      @first_successful_response ||=
        readers.lazy.map { |r| r.response(url) }.reject(&:nil?).first
    end

    attr_reader :url, :readers
  end
end
