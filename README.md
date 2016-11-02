# ScrapedPage

Write declarative scrapers in Ruby

## Usage

Create a subclass of `ScrapedPage` for each _type_ of page you wish to scrape.

For example if you were scraping a list of people you might have a
`PeopleListPage` class for the list page and a `PersonPage` class for an
individual person's page.

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

A strategy is an object that implements a `response` method which returns a
`Hash` with at least a `:body` key and optionally `:status` and `:headers` keys.

```ruby
class FilesystemStrategy
  def response(url)
    { body: File.read(Digest::SHA1.hexdigest(url) + '.html') }
  end
end
```

Then you can pass that strategy when creating an instance of your `ScrapedPage` subclass:

```ruby
ExamplePage.new(url: 'http://example.com', strategy: FilesystemStrategy.new)
```
