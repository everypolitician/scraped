require 'scraped_page/strategy/live_request'
require 'scraped_page_archive'

class ScrapedPage
  module Strategy
    class LiveRequestArchive < LiveRequest
      def response(url)
        log "Archiving #{url}"
        scraped_page_archive.record { super }
      end

      private

      def scraped_page_archive
        @scraped_page_archive ||= ScrapedPageArchive.new(
          ScrapedPageArchive::GitStorage.new
        )
      end
    end
  end
end
