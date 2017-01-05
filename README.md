# Scraped

Scraped: write declarative webscrapers in Ruby.

Scraped is a gem that knows you want to hit a page to extract data — typically repetively — as fields, ready to drop into a database. Tell Scraped where and how (simplest: at URL) to find the page or pages, make a class for each  different types of thing it needs to find, and, for each of those, the fields you want it to extract.

We (the EveryPolitician team) need to scrape a _lot_ of websites, extracting politicians' data from them. The Scraped gem is how we manage to stay on top
of hundreds of scrapers. [Read more](FIXME).

## Usage in a nutshell

Tell Scraped...

* the classes for pages (or sections) you want
** the fields you want, expressed as noko expressions (CSS of XPATH)
* the *strategy* for recovering them
** maybe it's just open-uri to a URL?
** or perhaps you also want to archive as you go?
** or be fancy and read from the archive, pulling from upstream if the site's available
* *decorate* what comes back before using it: for example, maybe you need to:
** make relative URLs absolute
** unspan HTML tables (flatten out the colspans or rowspans)
** normalise whitespace (nobody likes &nbsp; in their data)

Scraped hits the page or pages and returns them as object of the classes you want, ready to use. This plays very nicely with morph.io; or simply run it locally and write your own CSV or into your favourite database.

We have examples of this in action: try [here](FIXME) or [here](FIXME) or [here](FIXME).

## Simple example:

```ruby
FIXME
FIXME
FIXME
FIXME
````

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'scraped'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scraped

## Usage

To write a standard HTML scraper, start by creating a subclass of
`Scraped::HTML` for each _type_ of page you wish to scrape.

For example if you were scraping a list of people you might have a
`PeopleListPage` class for the list page and a `PersonPage` class for an
individual person's page.

```ruby
require 'scraped'

class ExamplePage < Scraped::HTML
  field :title do
    noko.at_css('h1').text
  end

  field :more_information do
    noko.at_css('a')[:href]
  end
end
```

Then you can create a new instance and pass in a `Scraped::Response` instance.

```ruby
page = ExamplePage.new(response: Scraped::Request.new(url: 'http://example.com').response)

page.title
# => "Example Domain"

page.more_information
# => "http://www.iana.org/domains/reserved"

page.to_h
# => { :title => "Example Domain", :more_information => "http://www.iana.org/domains/reserved" }
```

### Dealing with sections of a page

When writing an HTML scraper you'll often need to deal with just a part of the page.
For example you might want to scrape a table containing a list of people and some
associated data.

To do this you can use the `fragment` method, passing it a hash with one entry
where the key is the `noko` fragment you want to use and the value is the class
that should handle that fragment.

```ruby
class MemberRow < Scraped::HTML
  field :name do
    noko.css('td')[2].text
  end

  field :party do
    noko.css('td')[3].text
  end
end

class AllMembersPage < Scraped::HTML
  field :members do
    noko.css('table.members-list tr').map do |row|
      fragment row => MemberRow
    end
  end
end
```

### Passing request headers

To set request headers you can pass a `headers:` argument to `Scraped::Request.new`:

```ruby
response = Scraped::Request.new(url: 'http://example.com', headers: { 'Cookie' => 'user_id' => '42' }).response
page = ExamplePage.new(response: response)
```

## Extending

There are two main ways to extend `scraped` with your own custom logic - custom requests and decorated responses. Custom requests allow you to change where the scraper is getting its responses from, e.g. you might want to make requests to archive.org if the site you're scraping has disappeared. Decorated responses allow you to manipulate the response before it's passed to the scraper. Scraped comes with some [built in decorators](#built-in-decorators) for common tasks such as making all the link urls on the page absolute rather than relative.

### Custom request strategies

To make a custom request you'll need to create a class that subclasses `Scraped::Request::Strategy` and defines a `response` method.

```ruby
class FileOnDiskRequest < Scraped::Request::Strategy
  def response
    { body: open(filename).read }
  end

  private

  def filename
    @filename ||= File.join(URI.parse(url).host, Digest::SHA1.hexdigest(url))
  end
end
```

The `response` method should return a `Hash` which has at least a `body` key. You can also include `status` and `headers` parameters in the hash to fill out those fields in the response. If not given, status will default to `200` (OK) and headers will default to `{}`.

To use a custom request strategy pass it to `Scraped::Request`:

```ruby
request = Scraped::Request.new(url: 'http://example.com', strategies: [FileOnDiskRequest, Scraped::Request::Strategy::LiveRequest])
page = MyPersonPage.new(response: request.response)
```

### Decorated responses

To manipulate the response before it is processed by the scraper create a class that subclasses `Scraped::Response::Decorator` and defines any of the following methods: `body`, `url`, `status`, `headers`.

```ruby
class AbsoluteLinks < Scraped::Response::Decorator
  def body
    doc = Nokogiri::HTML(super)
    doc.css('a').each do |link|
      link[:href] = URI.join(url, link[:href]).to_s
    end
    doc.to_s
  end
end
```

As well as the `body` method you can also supply your own `url`, `status` and `headers` methods. You can access the current request body by calling `super` from your method. You can also call `url`, `headers` or `status` to access those properties of the current response.

To use a response decorator you need to use the `decorator` class method in a `Scraped::HTML` subclass:

```ruby
class PageWithRelativeLinks < Scraped::HTML
  decorator AbsoluteLinks

  # Other fields...
end
```

### Configuring requests and responses

When passing an array of request strategies or response decorators you should always pass the class, rather than the instance. If you want to configure an instance you can pass in a two element array where the first element is the class and the second element is the config:

```ruby
class CustomHeader < Scraped::Response::Decorator
  def headers
    response.headers.merge('X-Greeting' => config[:greeting])
  end
end

class ExamplePage < Scraped::HTML
  decorator CustomHeader, greeting: 'Hello, world'
end
```

With the above code a custom header would be added to the response: `X-Greeting: Hello, world`.

#### Inheritance with decorators

When you inherit from a class that already has decorators the child class will also inherit the parent's decorators. There's currently no way to re-order or remove decorators in child classes, though that _may_ be added in the future.

### Built in decorators

#### Clean link and image URLs

You will likely want to normalize link and image urls on the page you are scraping. `Scraped::Response::Decorator::CleanUrls` ensures that each link is absolute and does not contain any encoded characters.

```ruby
require 'scraped'

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :image do
    # Image url will be absolute and encoded correctly thanks to the decorator.
    noko.at_css('.profile-picture/@src').text
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/scraped.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
