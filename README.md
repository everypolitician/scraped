# ScrapedPage

Write declarative scrapers in Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scraped_page'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scraped_page

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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/scraped_page.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
