require 'nokogiri'
require 'uri'

module Scraped
  class Response
    class Decorator
      class AbsoluteUrls < Decorator
        def body
          Nokogiri::HTML(super).tap do |doc|
            doc.css('img').each { |img| img[:src] = absolute_url(img[:src]) }
            doc.css('a').each { |a| a[:href] = absolute_url(a[:href]) }
          end.to_s
        end

        private

        def absolute_url(relative_url)
          unless relative_url.to_s.empty?
            URI.join(url, URI.encode(
              # To prevent encoded URLs from being encoded twice
              URI.decode(relative_url)
            ).gsub('[', '%5B').gsub(']', '%5D')).to_s
          end
        rescue URI::InvalidURIError => e
          warn "[#{self.class}] Could not make #{relative_url.inspect} absolute: #{e.message}" if ENV['VERBOSE']
          relative_url
        end
      end
    end
  end
end
