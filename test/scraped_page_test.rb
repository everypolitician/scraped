require 'test_helper'

describe ScrapedPage do
  it 'has a version number' do
    ::ScrapedPage::VERSION.wont_be_nil
  end

  class TestPage < ScrapedPage
    field :foo do
      noko.css('h1').text
    end
  end

  class TestStrategy
    def get(url)
      ScrapedPage::Response.new(body: "<h1>Welcome to #{url}</h1>")
    end
  end

  describe 'a simple scraper' do
    it 'serializes to a hash' do
      page = TestPage.new('http://example.com', strategy: TestStrategy.new)
      page.to_h.must_equal foo: 'Welcome to http://example.com'
    end
  end
end
