# frozen_string_literal: true
require 'scraped/version'
require 'scraped/strategy/live_request'
require 'scraped/strategy/live_request_archive'
require 'scraped/request'
require 'scraped/response'
require 'nokogiri'
require 'field_serializer'

# Abstract class which scrapers can extend to implement their functionality.
class Scraped
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
