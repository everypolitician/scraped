require 'test_helper'

describe Scraped::HTML do
  describe 'accessing HTML via nokogiri' do
    let(:html) do
      <<-HTML
<p class="test-content">Hi there!</p>
<p class="name">Members Page</p>
<div class="member-info">
  <p class="name">Alice</p>
</div>
      HTML
    end

    let(:response) do
      Scraped::Response.new(
        body: html,
        url:  'http://example.com'
      )
    end

    class MemberInfo < Scraped::HTML
      field :name do
        noko.css('.name').text
      end
    end

    class ExamplePage < Scraped::HTML
      field :content do
        noko.css('.test-content').text
      end

      field :member do
        fragment noko.css('.member-info') => MemberInfo
      end
    end

    let(:page) { ExamplePage.new(response: response) }

    it 'returns the expected content' do
      page.content.must_equal 'Hi there!'
    end

    describe 'with a custom noko instance' do
      let(:fragment) do
        Nokogiri::HTML.fragment('<p class="test-content">Replacement</p>')
      end

      let(:page) { ExamplePage.new(response: response, noko: fragment) }

      it 'returns the replacement content' do
        page.content.must_equal 'Replacement'
      end
    end

    describe 'fragment method' do
      let(:page) { ExamplePage.new(response: response) }

      it 'returns content from a subset of the page' do
        page.member.name.must_equal 'Alice'
      end
    end
  end
end
