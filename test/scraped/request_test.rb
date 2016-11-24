require 'test_helper'

class TestStrategy < Scraped::Request::Strategy
  def response
    { body: response_body }
  end

  private

  def response_body
    config[:body] || 'Hello, world'
  end
end

describe Scraped::Request do
  describe 'with a single strategy' do
    let(:response) do
      Scraped::Request.new(
        url:        'http://example.com',
        strategies: [TestStrategy]
      ).response
    end

    it 'returns the response instance from the strategy' do
      response.body.must_equal 'Hello, world'
    end
  end

  describe 'with multiple valid strategies' do
    let(:response) do
      Scraped::Request.new(
        url:        'http://example.com',
        strategies: [
          { strategy: TestStrategy, body: 'First' },
          { strategy: TestStrategy, body: 'Second' },
        ]
      ).response
    end

    it 'returns the response from the first' do
      response.body.must_equal 'First'
    end
  end
end
