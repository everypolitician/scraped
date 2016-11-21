require 'open-uri'

class Scraped
  module Strategy
    class LiveRequest
      def response(url)
        log "Fetching #{url}"
        response = open(url)
        {
          status:  response.status.first.to_i,
          headers: response.meta,
          body:    response.read,
        }
      end

      private

      def log(message)
        warn "[#{self.class}] #{message}" if ENV.key?('VERBOSE')
      end
    end
  end
end
