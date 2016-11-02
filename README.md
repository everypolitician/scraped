# ScrapedPage

Write declarative scrapers in Ruby

## Usage

Create a subclass of `ScrapedPage` for each page you wish to scrape.

```ruby
require 'scraped_page'

class ExamplePage < ScrapedPage
  field :title do
    noko.at_css('h1').text
  end

  field :more_information do
    noko.at_css('a')[:href]
  end
end
```

Then you can create a new instance and pass in a url

```ruby
page = ExamplePage.new(url: 'http://example.com')

page.title
# => "Example Domain"

page.more_information
# => "http://www.iana.org/domains/reserved"

page.to_h
# => { :title => "Example Domain", :more_information => "http://www.iana.org/domains/reserved" }
```

The default strategy for retrieving pages is to make an http request to retrieve them. If you'd also like to archive a copy of the page you're scraping into a git branch, you can pass a `:strategy` option to the constructor:

```ruby
ExamplePage.new('http://example.com', strategy: ScrapedPage::Strategy::LiveRequestArchive.new)
```
