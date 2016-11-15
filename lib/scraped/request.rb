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
      abort "Couldn't find a response for #{url}" if readers_response.nil?
      response = Response.new(readers_response.merge(url: url))
      writers.each { |w| w.save_response(response) }
      response
    end

    private

    def readers_response(url)
      @readers_response ||=
        readers.lazy.map { |r| r.response(url) }.reject(&:nil?).first
    end

    attr_reader :url, :readers, :writers
  end
end
