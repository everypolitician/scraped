require 'scraped/strategy/live_request'
require 'scraped/response'

class Scraped
  class Request
    def initialize(url:, readers: [Strategy::LiveRequest.new], writers: [])
      @url = url
      @readers = readers
      @writers = writers
    end

    def response
      abort "Failed to fetch #{url}" if first_successful_response.nil?
      response = Response.new(first_successful_response.merge(url: url))
      writers.each { |w| w.save_response(response) }
      response
    end

    private

    def first_successful_response
      @first_successful_response ||=
        readers.lazy.map { |r| r.response(url) }.reject(&:nil?).first
    end

    attr_reader :url, :readers, :writers
  end
end
