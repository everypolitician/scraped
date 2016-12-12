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

    class FindReplaceDecorator < Scraped::Response::Decorator
      def body
        super.gsub(config[:find], config[:replace])
      end
    end

    class PageNoDecorators < Scraped
      field :body do
        response.body.to_s
      end
    end

    class PageWithDecorators < PageNoDecorators
      decorator UpcaseDecorator
    end

    class PageWithConfigurableDecorators < PageNoDecorators
      decorator FindReplaceDecorator, find: 'Hello', replace: 'Hi!'
    end

    class PageWithMultipleDecorators < PageNoDecorators
      decorator FindReplaceDecorator, find: 'Hello', replace: 'Hi!'
      decorator UpcaseDecorator
    end

    class PageInheritingDecorators < PageWithDecorators
    end

    it 'does not change the response with no decorators' do
      PageNoDecorators.new(response: response).body.must_equal 'Hello'
    end

    it 'changes the body with decorator' do
      PageWithDecorators.new(response: response).body.must_equal 'HELLO'
    end

    it 'allows configuring decorators' do
      PageWithConfigurableDecorators.new(
        response: response
      ).body.must_equal 'Hi!'
    end

    it 'works with multiple decorators' do
      PageWithMultipleDecorators.new(
        response: response
      ).body.must_equal 'HI!'
    end

    it 'works with inheritance' do
      PageInheritingDecorators.new(
        response: response
      ).body.must_equal 'HELLO'
    end
  end
end
