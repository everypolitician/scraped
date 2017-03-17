require 'test_helper'

describe Scraped::Request::Strategy do
  class TestConfigurableStrategy < Scraped::Request::Strategy
    def response
      { body: "Hello, #{config[:name]}, welcome to #{url}" }
    end

    private

    def name
      config[:name] || 'world'
    end
  end

  describe 'with a valid response method' do
    let(:response) do
      TestConfigurableStrategy.new(
        url:    'http://example.com',
        config: { name: 'Alice' }
      ).response
    end

    it 'returns the expected response' do
      response[:body].must_equal 'Hello, Alice, welcome to http://example.com'
    end
  end

  describe 'with no response method' do
    it 'raises an error' do
      lambda do
        Scraped::Request::Strategy.new(url: 'http://example.com').response
      end.must_raise Scraped::Request::Strategy::NotImplementedError
    end
  end

  describe 'passing request headers' do
    class TestHeadersStrategy < Scraped::Request::Strategy
      def response
        { body: "Status: #{headers['X-Testing-Status']}" }
      end
    end

    let(:response) do
      TestHeadersStrategy.new(
        url:     'http://example.com',
        headers: {
          'X-Testing-Status' => 'Test successful',
        },
        config:  { name: 'Alice' }
      ).response
    end

    it 'makes the headers available to the strategy' do
      response[:body].must_equal 'Status: Test successful'
    end
  end
end
