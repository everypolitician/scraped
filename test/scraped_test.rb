require 'test_helper'

describe Scraped do
  it 'has a version number' do
    ::Scraped::VERSION.wont_be_nil
  end

  describe 'decorators' do
    let(:response) do
      Scraped::Response.new(body: 'Hello', url: 'http://example.com')
    end

    class UpcaseDecorator < Scraped::Response::Decorator
      def body
        super.upcase
      end
    end

    class PageNoDecorators < Scraped
      field :body do
        response.body.to_s
      end
    end

    class PageWithDecorators < PageNoDecorators
      decorators [UpcaseDecorator]
    end

    it 'does not change the response with no decorators' do
      PageNoDecorators.new(response: response).body.must_equal 'Hello'
    end

    it 'changes the body with decorator' do
      PageWithDecorators.new(response: response).body.must_equal 'HELLO'
    end
  end
end
