# frozen_string_literal: true
require 'scraped_page/version'

require 'nokogiri'
require 'open-uri'
require 'field_serializer'
require 'scraped_page_archive'

# Abstract class which scrapers can extend to implement their functionality.
class ScrapedPage
  include FieldSerializer

  class Response
    attr_reader :status, :headers, :body

    def initialize(body:, status: 200, headers: {})
      @status = status
      @headers = headers
      @body = body
    end
  end

  module Strategy
    class LiveRequest
      def response(url)
        log "Fetching #{url}"
        response = open(url)
        {
          status:  response.status.first.to_i,
          headers: response.meta,
          body:    response.read,
        }
      end

      private

      def log(message)
        warn "[#{self.class}] #{message}"
      end
    end

    class LiveRequestArchive < LiveRequest
      def response(url)
        log "Archiving #{url}"
        scraped_page_archive.record { super }
      end

      private

      def scraped_page_archive
        @scraped_page_archive ||= ScrapedPageArchive.new(
          ScrapedPageArchive::GitStorage.new
        )
      end
    end
  end

  def initialize(url:, strategy: Strategy::LiveRequest.new)
    @url = url
    @strategy = strategy
  end

  private

  attr_reader :url, :strategy

  def noko
    @noko ||= Nokogiri::HTML(response.body)
  end

  def response
    @response ||= Response.new(strategy.response(url))
  end
end
