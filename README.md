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

Create a subclass of `Scraped` for each _type_ of page you wish to scrape.

For example if you were scraping a list of people you might have a
`PeopleListPage` class for the list page and a `PersonPage` class for an
individual person's page.

```ruby
require 'scraped'

class ExamplePage < Scraped
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

## Extending

There are two main ways to extend `scraped` with your own custom logic - custom requests and decorated responses. Custom requests allow you to change where the scraper is getting its responses from, e.g. you might want to make requests to archive.org if the site you're scraping has disappeared. Decorated responses allow you to manipulate the response before it's passed to the scraper. For example you might want to make all the links on the page absolute rather than relative.

### Custom request strategies

To make a custom request you'll need to create a class that subclasses `Scraped::Request::Strategy` and defines a `response` method.

```ruby
class FileOnDiskRequest < Scraped::Request::Strategy
  def response
    Response.new(url: url, body: open(filename).read)
  end

  private

  def filename
    @filename ||= File.join(URI.parse(url).host, Digest::SHA1.hexdigest(url))
  end
end
```

The `response` method should return a `Response` instance. You need to pass at least `url` and `body` parameters to the `Response` constructor. You can also pass `status` and `headers` parameters.

To use a custom request strategy pass it to `Scraped::Request`:

```ruby
request = Scraped::Request.new(url: 'http://example.com', strategies: [FileOnDiskRequest, Scraped::Request::Strategy::LiveRequest])
page = MyPersonPage.new(response: request.response)
```

### Decorated responses

To manipulate the response before it is passed to the scraper create a class that subclasses `Scraped::Response::Decorator` and defines any of the following methods: `body`, `url`, `status`, `headers`.

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

To use a response decorator you need to supply it to the `Request#response` method:

```ruby
request = Scraped::Request.new(url: 'http://example.com')
response = request.response(decorators: [AbsoluteLinks])
```

### Configurating requests and responses

When passing an array of request strategies or response decorators you should always pass the class, rather than the instance. If you want to configure an instance you can pass in a two element array where the first element is the class and the second element is the config:

```ruby
class CustomHeader < Scraped::Response::Decorator
  def headers
    response.headers.merge('X-Greeting' => config[:greeting])
  end
end

response = Scraped::Request.new(url: url).response([
  [CustomHeader, greeting: 'Hello, world']
])
```

With the above code a custom header would be added to the response: `X-Greeting: Hello, world`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/everypolitician/scraped.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
