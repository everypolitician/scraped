require 'scraped'

class ExamplePage < Scraped::HTML
  field :title do
    noko.at_xpath('//h1').text
  end

  field :more_info_url do
    noko.at_css('a')[:href]
  end
end

page = ExamplePage.new(response: Scraped::Request.new(url: 'http://example.com').response)

puts page.title
puts page.more_info_url