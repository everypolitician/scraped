# frozen_string_literal: true
require 'nokogiri'
require 'field_serializer'
require 'require_all'
require_rel 'scraped'

# Abstract class which scrapers can extend to implement their functionality.
class Scraped
  include FieldSerializer

  def initialize(response:)
    @response = response
  end

  private

  attr_reader :response

  def url
    response.url
  end

  def noko
    @noko ||= Nokogiri::HTML(response.body)
  end
end
