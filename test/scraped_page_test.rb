require 'test_helper'

describe ScrapedPage do
  it 'has a version number' do
    ::ScrapedPage::VERSION.wont_be_nil
  end

  class TestPage < ScrapedPage
    field :foo do
      noko.css('h1')
    end
  end

  class TestStrategy < ScrapedPage::Strategy
  end

  describe 'a simple scraper' do
    it 'serializes to a hash' do
      page = TestPage.new('http://example.com', strategy: TestStrategy)
      page.to_h.must_equal foo: 'bar'
    end
  end
end
