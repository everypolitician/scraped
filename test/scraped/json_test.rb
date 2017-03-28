require 'test_helper'
require 'pry'

describe Scraped::JSON do
  describe 'accessing JSON via nokogiri' do
    let(:json) do
      <<-JSON
        {
          "test_content": "Hi there!",
          "member_info": {
            "name": "Alice"
          }
        }
      JSON
    end

    let(:response) do
      Scraped::Response.new(
        body: json,
        url:  'http://example.com'
      )
    end

    class JSONMemberInfo < Scraped::JSON
      field :name do
        json[:name]
      end
    end

    class JSONExamplePage < Scraped::JSON
      field :content do
        json[:test_content]
      end

      field :member do
        fragment json[:member_info] => JSONMemberInfo
      end
    end

    let(:page) { JSONExamplePage.new(response: response) }

    it 'returns the expected content' do
      page.content.must_equal 'Hi there!'
    end

    describe 'fragment method' do
      let(:page) { JSONExamplePage.new(response: response) }

      it 'returns content from a subset of the page' do
        page.member.name.must_equal 'Alice'
      end
    end
  end
end
