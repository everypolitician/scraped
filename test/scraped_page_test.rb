require 'test_helper'

describe ScrapedPage do
  it 'has a version number' do
    ::ScrapedPage::VERSION.wont_be_nil
  end

  describe 'a simple scraper' do
    it 'serializes to a hash' do
      ScrapedPage.new.to_h.must_equal({})
    end
  end
end
