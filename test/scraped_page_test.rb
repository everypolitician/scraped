require 'test_helper'

describe ScrapedPage do
  it 'has a version number' do
    ::ScrapedPage::VERSION.wont_be_nil
  end
end
