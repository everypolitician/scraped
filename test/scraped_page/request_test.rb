require 'test_helper'

describe ScrapedPage::Request do
  describe 'reading a request' do
    class MockRequest
      def response(_url)
        { body: 'Hello, world' }
      end
    end

    subject do
      ScrapedPage::Request.new(
        url:     'http://example.com',
        readers: [MockRequest.new]
      )
    end

    let(:response) { subject.response }

    it 'returns a response for the request' do
      response.body.must_equal 'Hello, world'
      response.status.must_equal 200
      response.headers.must_equal({})
      response.url.must_equal 'http://example.com'
    end
  end

  describe 'writing a request' do
  end

  describe 'failed request' do
  end
end
