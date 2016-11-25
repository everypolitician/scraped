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

    let(:page) { ExamplePage.new(response: response) }

    it 'returns the expected content' do
      page.content.must_equal 'Hi there!'
    end

    describe 'with a custom noko instance' do
      let(:fragment) do
        Nokogiri::HTML.fragment('<p class="test-content">Replacement</p>')
      end

      let(:page) { ExamplePage.new(response: response, noko: fragment) }

      it 'returns the replacement content' do
        page.content.must_equal 'Replacement'
      end
    end
  end
end
