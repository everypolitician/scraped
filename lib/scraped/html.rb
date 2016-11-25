class Scraped
  class HTML < Scraped
    private

    def initialize(noko: nil, **args)
      super(**args)
      @noko = noko
    end

    def noko
      @noko ||= Nokogiri::HTML(response.body)
    end
  end
end
