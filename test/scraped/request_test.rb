require 'test_helper'

describe Scraped::Request do
  class TestStrategy < Scraped::Request::Strategy
    def response
      { body: response_body }
    end

    private

    def response_body
      config[:body] || 'Hello, world'
    end
  end

  describe 'request strategies' do
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

    describe 'with an invalid and a valid strategy' do
      class FailingStrategy < Scraped::Request::Strategy
        def response
          nil
        end
      end

      let(:response) do
        Scraped::Request.new(
          url:        'http://example.com',
          strategies: [
            FailingStrategy,
            { strategy: TestStrategy, body: 'Success' },
          ]
        ).response
      end

      it 'returns the body of the first successful strategy' do
        response.body.must_equal 'Success'
      end
    end
  end

  describe 'decorators' do
    class FindReplaceDecorator < Scraped::Response::Decorator
      def body
        super.gsub(config[:find], config[:replace])
      end
    end

    class UpcaseDecorator < Scraped::Response::Decorator
      def body
        super.upcase
      end
    end

    describe 'with a simple decorator' do
      let(:response) do
        Scraped::Request.new(
          url:        'http://example.com',
          strategies: [TestStrategy]
        ).response(
          decorators: [
            {
              decorator: FindReplaceDecorator,
              find:      'world',
              replace:   'earth',
            },
          ]
        )
      end

      it 'processes the body with the decorator' do
        response.body.must_equal 'Hello, earth'
      end
    end

    describe 'with multiple decorators' do
      let(:response) do
        Scraped::Request.new(
          url:        'http://example.com',
          strategies: [TestStrategy]
        ).response(
          decorators: [
            {
              decorator: FindReplaceDecorator,
              find:      'world',
              replace:   'earth',
            },
            UpcaseDecorator,
          ]
        )
      end

      it 'processes the body with all decorators' do
        response.body.must_equal 'HELLO, EARTH'
      end
    end
  end
end
