# frozen_string_literal: true
require 'scraped_page/version'
require 'scraped_page/strategy/live_request'
require 'scraped_page/strategy/live_request_archive'
require 'scraped_page/request'
require 'scraped_page/response'
require 'nokogiri'
require 'field_serializer'

# Abstract class which scrapers can extend to implement their functionality.
class ScrapedPage
  include FieldSerializer

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
