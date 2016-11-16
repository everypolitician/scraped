# frozen_string_literal: true
require 'nokogiri'
require 'field_serializer'
require 'require_all'
require_rel 'scraped'

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
