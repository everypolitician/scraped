require 'test_helper'

describe Scraped::Response::Decorator::AbsoluteUrls do
  let(:body) do
    <<-BODY
    <img class="relative-image" src="/person-123.jpg">
    <img class="absolute-image" src="http://example.com/person-123-square.jpg">
    <img class="external-image" src="http://example.org/person-123-alternative.jpg">
    <img class="empty-image" src="">

    <a class="relative-link" href="/person-123">Person 123</a>
    <a class="absolute-link" href="http://example.com/person-123-contact">Person 123</a>
    <a class="external-link" href="http://example.org/person-123-other-page">Person 123</a>
    <a class="empty-link" href="">Person 123</a>
    <a class="javascript-link" href="javascript:chooseStyle('small',60);">Person 123</a>
    <a class="bracketed-link" href="/person[123]">Person 123</a>
    <a class="relative-link-with-unencoded-space" href="/person 123">Person 123</a>
    <a class="encoded-url" href="/person%20123">Person 123</a>
    BODY
  end

  let :body_with_base do
    <<-BODY
    <base href="http://www.example.com/" />
    <a class="relative-link" href="/person-123">Person 123</a>
    BODY
  end

  let(:response) do
    Scraped::Response.new(url: 'http://example.com', body: body)
  end

  let :body_with_base_response do
    Scraped::Response.new(url: 'http://example.com', body: body_with_base)
  end

  let(:page) { PageWithAbsoluteUrlsDecorator.new(response: response) }
  let :page_with_base do
    PageWithAbsoluteUrlsDecorator.new(response: body_with_base_response)
  end

  class PageWithAbsoluteUrlsDecorator < Scraped::HTML
    decorator Scraped::Response::Decorator::AbsoluteUrls

    field :relative_image do
      img('.relative-image')
    end

    field :absolute_image do
      img('.absolute-image')
    end

    field :external_image do
      img('.external-image')
    end

    field :empty_image do
      img('.empty-image')
    end

    field :relative_link do
      link('.relative-link')
    end

    field :absolute_link do
      link('.absolute-link')
    end

    field :external_link do
      link('.external-link')
    end

    field :empty_link do
      link('.empty-link')
    end

    field :javascript_link do
      link('.javascript-link')
    end

    field :bracketed_link do
      link('.bracketed-link')
    end

    field :relative_link_with_unencoded_space do
      link('.relative-link-with-unencoded-space')
    end

    field :encoded_url do
      link('.encoded-url')
    end

    private

    def img(selector)
      noko.at_css("#{selector}/@src").text
    end

    def link(selector)
      noko.at_css("#{selector}/@href").text
    end
  end

  it 'makes relative images absolute' do
    page.relative_image.must_equal 'http://example.com/person-123.jpg'
  end

  it 'leaves absolute images alone' do
    page.absolute_image.must_equal 'http://example.com/person-123-square.jpg'
  end

  it 'leaves external images alone' do
    page.external_image.must_equal 'http://example.org/person-123-alternative.jpg'
  end

  it 'leaves empty image src attributes alone' do
    page.empty_image.must_equal ''
  end

  it 'makes relative links absolute' do
    page.relative_link.must_equal 'http://example.com/person-123'
  end

  it 'leaves absolute links alone' do
    page.absolute_link.must_equal 'http://example.com/person-123-contact'
  end

  it 'leaves external links alone' do
    page.external_link.must_equal 'http://example.org/person-123-other-page'
  end

  it "doesn't raise an exception for javascript links" do
    page.javascript_link.must_equal "javascript:chooseStyle('small',60);"
  end

  it 'leaves empty link href attributes alone' do
    page.empty_link.must_equal ''
  end

  it 'handles square brackets' do
    page.bracketed_link.must_equal 'http://example.com/person%5B123%5D'
  end

  it 'encodes space characters' do
    page.relative_link_with_unencoded_space.must_equal 'http://example.com/person%20123'
  end

  it 'should not encode already encoded URLs' do
    page.encoded_url.must_equal 'http://example.com/person%20123'
  end

  it 'should use a base url provided by the document' do
    page_with_base.relative_link.must_equal 'http://www.example.com/person-123'
  end
end
