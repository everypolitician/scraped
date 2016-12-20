require 'nokogiri'
require 'uri'

class Scraped
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
          URI.join(url, relative_url) unless relative_url.to_s.empty?
        rescue URI::InvalidURIError
          relative_url
        end
      end
    end
  end
end
