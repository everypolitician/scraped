class Scraped
  class HTML < Scraped
    def noko
      @noko ||= Nokogiri::HTML(response.body)
    end
  end
end
