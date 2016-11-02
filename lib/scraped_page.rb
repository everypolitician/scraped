require 'scraped_page/version'
require 'scraped_page/strategy'
require 'scraped_page/response'

require 'field_serializer'
require 'nokogiri'

class ScrapedPage
  include FieldSerializer

  def initialize(url, strategy: Strategy::LiveRequest.new)
    @url = url
    @strategy = strategy
  end

  private

  attr_reader :url, :strategy

  def noko
    @noko ||= Nokogiri::HTML(response.body)
  end

  def response
    @response ||= strategy.get(url)
  end
end
