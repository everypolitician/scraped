require 'nokogiri'
require 'uri'

module Scraped
  class Response
    class Decorator
      class CleanUrls < Decorator
        class AbsoluteUrl
          def initialize(base_url:, relative_url:)
            @base_url = base_url
            @relative_url = relative_url
          end

          def to_s
            unless relative_url.to_s.empty?
              URI.join(base_url, URI.encode(
                # To prevent encoded URLs from being encoded twice
                URI.decode(relative_url)
              ).gsub('[', '%5B').gsub(']', '%5D')).to_s
            end
          rescue URI::Error
            relative_url
          end

          private

          attr_reader :base_url, :relative_url
        end

        def body
          Nokogiri::HTML(super).tap do |doc|
            doc.css('img').each { |img| img[:src] = absolute_url(img[:src]) }
            doc.css('a').each { |a| a[:href] = absolute_url(a[:href]) }
          end.to_s
        end

        private

        def absolute_url(relative_url)
          AbsoluteUrl.new(base_url: url, relative_url: relative_url).to_s
        end
      end

      # The 'AbsoluteUrls' class was renamed to 'CleanUrls', so output a
      # deprecation warning when a user tries to use it.
      #
      # Modified version of http://myronmars.to/n/dev-blog/2011/09/deprecating-constants-and-classes-in-ruby
      def self.const_missing(const_name)
        super unless const_name == :AbsoluteUrls
        warn '`Scraped::Response::Decorator::AbsoluteUrls` has been deprecated. ' \
          'Use `Scraped::Response::Decorator::CleanUrls` instead.'
        CleanUrls
      end
    end
  end
end
