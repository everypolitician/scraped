module Scraped
  class Scraper
    def initialize(h)
      @url, @klass = h.to_a.first
    end

    def store(method, index: %i[id], table: 'data', clobber: true, debug: ENV['MORPH_DEBUG'])
      data = scraper.send(method)
      data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if debug
      ScraperWiki.sqliteexecute('DROP TABLE %s' % table) rescue nil if clobber
      ScraperWiki.save_sqlite(index, data, table)
    end

    def scraper
      klass.new(response: Scraped::Request.new(url: url).response)
    end

    private

    attr_reader :url, :klass
  end
end
