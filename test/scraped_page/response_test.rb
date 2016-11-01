require 'test_helper'

describe ScrapedPage::Response do
  subject { ScrapedPage::Response }

  describe 'body' do
    it 'is required' do
      -> { subject.new }.must_raise ArgumentError
    end

    it 'returns the passed in value' do
      subject.new(body: 'Hello, world').body.must_equal 'Hello, world'
    end
  end

  describe '#status' do
    it 'defaults to 200' do
      subject.new(body: 'foo').status.must_equal 200
    end

    it 'returns the passed in value' do
      subject.new(body: 'foo', status: 403).status.must_equal 403
    end
  end

  describe '#headers' do
    it 'defaults to {}' do
      subject.new(body: 'foo').headers.must_equal({})
    end

    it 'returns the passed in value' do
      headers = { 'Content-Type' => 'text/html' }
      subject.new(body: 'foo', headers: headers)
             .headers['Content-Type']
             .must_equal 'text/html'
    end
  end
end
