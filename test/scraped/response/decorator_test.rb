require 'test_helper'

describe Scraped::Response::Decorator do
  class NullDecorator < Scraped::Response::Decorator; end

  describe 'with no decorated methods' do
    let(:response) do
      Scraped::Response.new(
        body: 'Hello, world',
        url:  'http://example.com'
      )
    end

    let(:new_response) do
      NullDecorator.new(response: response).decorated_response
    end

    it 'returns an identical response' do
      new_response.url.must_equal response.url
      new_response.body.must_equal response.body
      new_response.headers.must_equal response.headers
      new_response.status.must_equal response.status
    end
  end

  describe 'with decorated methods' do
    class MultiDecorator < Scraped::Response::Decorator
      def url
        'http://example.net'
      end

      def body
        'Fancy body'
      end

      def headers
        { 'Foo' => 'bar' }
      end

      def status
        418
      end
    end

    let(:response) do
      Scraped::Response.new(
        body: 'Hello, world',
        url:  'http://example.com'
      )
    end

    let(:new_response) do
      MultiDecorator.new(response: response).decorated_response
    end

    it 'returns the decorated values' do
      new_response.url.must_equal 'http://example.net'
      new_response.body.must_equal 'Fancy body'
      new_response.headers.must_equal 'Foo' => 'bar'
      new_response.status.must_equal 418
    end
  end
end
