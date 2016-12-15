# Scraped

Write declarative scrapers in Ruby

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

To do this you can pass a `noko` keyword argument to a `Scraped::HTML` subclass
constructor. This will then replace the `noko` Nokogiri instance in the scraper
with the one you specify.

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
      MemberRow.new(response: response, noko: row)
    end
  end
end
```

## Extending

There are two main ways to extend `scraped` with your own custom logic - custom requests and decorated responses. Custom requests allow you to change where the scraper is getting its responses from, e.g. you might want to make requests to archive.org if the site you're scraping has disappeared. Decorated responses allow you to manipulate the response before it's passed to the scraper. For example you might want to make all the links on the page absolute rather than relative.

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

#### Absolute link and image urls

Very frequently you will find that you need to make links and images on the page
you are scraping absolute rather than relative. Scraped comes with support for
this out of the box via the `Scraped::Response::Decorator::AbsoluteUrls`
decorator.

```ruby
require 'scraped'

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :image do
    # Image url will be absolute thanks to the decorator.
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
