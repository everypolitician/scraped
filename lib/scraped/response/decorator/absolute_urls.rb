require 'nokogiri'
require 'uri'

class Scraped
  class Response
    class Decorator
      class AbsoluteUrls < Decorator
        def body
          Nokogiri::HTML(super).tap do |doc|
            doc.css('img').each { |img| img[:src] = URI.join(url, img[:src]) }
            doc.css('a').each { |a| a[:href] = URI.join(url, a[:href]) }
          end.to_s
        end
      end
    end
  end
end
