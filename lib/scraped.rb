# frozen_string_literal: true
require 'require_all'
require_rel 'scraped'

module Scraped
  def self.scrape(h)
    url, klass = h.to_a.first
    klass.new(response: Scraped::Request.new(url: url).response)
  end
end
