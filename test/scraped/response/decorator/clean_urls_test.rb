require 'test_helper'

describe Scraped::Response::Decorator::CleanUrls do
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
    <a class="broken-mailto-link" href="mailto:notanemail">Person 123</a>
    BODY
  end

  let(:response) do
    Scraped::Response.new(url: 'http://example.com', body: body)
  end

  let(:page) { PageWithCleanUrlsDecorator.new(response: response) }

  class PageWithCleanUrlsDecorator < Scraped::HTML
    decorator Scraped::Response::Decorator::CleanUrls

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

    field :broken_mailto_link do
      link('.broken-mailto-link')
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

  it 'ignores invalid mailto links' do
    page.broken_mailto_link.must_equal 'mailto:notanemail'
  end

  describe 'AbsoluteUrls' do
    it 'returns CleanUrls' do
      check_warning = lambda do |msg|
        msg.must_equal '`Scraped::Response::Decorator::AbsoluteUrls` has been deprecated. ' \
          'Use `Scraped::Response::Decorator::CleanUrls` instead.'
        nil
      end

      Scraped::Response::Decorator.stub(:warn, check_warning) do
        Scraped::Response::Decorator::AbsoluteUrls.must_equal Scraped::Response::Decorator::CleanUrls
      end
    end
  end
end
