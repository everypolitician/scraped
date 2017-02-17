require 'nokogiri'
require 'uri'

module Scraped
  class Response
    class Decorator
      class AbsoluteUrls < Decorator
        def body
          Nokogiri::HTML(super).tap do |doc|
            @doc = doc
            doc.css('img').each { |img| img[:src] = absolute_url(img[:src]) }
            doc.css('a').each { |a| a[:href] = absolute_url(a[:href]) }
          end.to_s
        end

        private

        attr_reader :doc

        def absolute_url(relative_url)
          unless relative_url.to_s.empty?
            URI.join(base_url, URI.encode(
              # To prevent encoded URLs from being encoded twice
              URI.decode(relative_url)
            ).gsub('[', '%5B').gsub(']', '%5D')).to_s
          end
        rescue URI::InvalidURIError
          relative_url
        end

        def base_url
          return url if (base = doc.css('base @href').text).empty?
          base
        end
      end
    end
  end
end
