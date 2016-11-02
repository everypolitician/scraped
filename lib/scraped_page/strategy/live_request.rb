require 'open-uri'

class ScrapedPage
  module Strategy
    class LiveRequest
      def get(url)
        response = open(url)
        Response.new(
          status:  response.status.first.to_i,
          headers: response.meta,
          body:    response.read
        )
      end
    end
  end
end
