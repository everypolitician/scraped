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

## Archiving scraped pages

The default strategy for retrieving pages is `ScrapedPage::Strategy::LiveRequest`. If you'd also like to archive a copy of the page you're scraping into a git branch, you can pass a `:strategy` option to the constructor:

```ruby
ExamplePage.new(url: 'http://example.com', strategy: ScrapedPage::Strategy::LiveRequestArchive.new)
```

This will use the [`scraped_page_archive`](https://github.com/everypolitician/scraped_page_archive)
gem to store a copy of the pages you scrape in a git branch in your scraper's repo.

## Custom strategies

If for some reason you can't scrape a site using one of the built in strategies
then you can provide your own strategy.

A strategy is an object that responds to a `get` method and returns a
`ScrapedPage::Response`.

```ruby
class FilesystemStrategy
  def get(url)
    body = File.read(Digest::SHA1.hexdigest(url) + '.html')
    ScrapedPage::Response.new(body: body)
  end
end
```

Then you can pass that strategy when creating an instance of your `ScrapedPage` subclass:

```ruby
ExamplePage.new(url: 'http://example.com', strategy: FilesystemStrategy.new)
```
