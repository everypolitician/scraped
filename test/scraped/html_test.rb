require 'test_helper'

describe Scraped::HTML do
  describe 'accessing HTML via nokogiri' do
    let(:response) do
      Scraped::Response.new(
        body: '<p class="test-content">Hi there!</p>',
        url:  'http://example.com'
      )
    end

    class ExamplePage < Scraped::HTML
      field :content do
        noko.css('.test-content').text
      end
    end

    it 'returns the expected content' do
      ExamplePage.new(response: response).content.must_equal 'Hi there!'
    end
  end
end
