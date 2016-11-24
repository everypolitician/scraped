class Scraped
  class HTML < Scraped
    private

    def noko
      @noko ||= Nokogiri::HTML(response.body)
    end
  end
end
