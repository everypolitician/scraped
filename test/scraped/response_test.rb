require 'test_helper'

describe Scraped::Response do
  describe 'with a body and a url' do
    subject do
      Scraped::Response.new(body: 'Hello, world', url: 'http://example.org')
    end

    it 'has the correct body' do
      subject.body.must_equal 'Hello, world'
    end

    it 'has the correct url' do
      subject.url.must_equal 'http://example.org'
    end

    it 'has a default status of 200' do
      subject.status.must_equal 200
    end

    it 'defaults to an empty hash for headers' do
      subject.headers.must_equal({})
    end
  end

  describe 'with a custom status' do
    subject do
      Scraped::Response.new(
        body:   'Hello, world',
        url:    'http://example.org',
        status: 418
      )
    end

    it 'returns the custom status' do
      subject.status.must_equal 418
    end
  end

  describe 'with custom headers' do
    subject do
      Scraped::Response.new(
        body:    'Hello, world',
        url:     'http://example.org',
        headers: {
          'Content-Type' => 'text/html',
          'X-Person-Id'  => 'alice-42',
        }
      )
    end
  end
end
