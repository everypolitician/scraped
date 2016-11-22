require 'scraped/request/strategy/live_request'
require 'scraped_page_archive'

class Scraped
  class Request
    class Strategy
      class LiveRequestArchive < LiveRequest
        def response
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
end
