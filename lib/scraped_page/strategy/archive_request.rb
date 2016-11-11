require 'open-uri'
require 'yaml'
require 'digest'
require 'uri'

class ScrapedPage
  module Strategy
    class ArchiveRequest
      Error = Class.new(StandardError)

      def response(url)
        ScrapedPageArchive::GitStorage.new.chdir do
          filename = filename_from_url(url.to_s)
          meta = YAML.load_file(filename + '.yml') if File.exist?(filename + '.yml')
          response_body = File.read(filename + '.html') if File.exist?(filename + '.html')
          unless meta && response_body
            fail Error, "No archived copy of #{url} found."
          end
          response = response_from(meta, response_body)
          { body: response.read, status: response.status.first.to_i, headers: response.meta }
        end
      end

      private

      def filename_from_url(url)
        File.join(URI.parse(url).host, Digest::SHA1.hexdigest(url))
      end

      def response_from(meta, response_body)
        StringIO.new(response_body).tap do |response|
          OpenURI::Meta.init(response)
          Hash(meta['response']['headers']).each { |k, v| response.meta_add_field(k, v.join(', ')) }
          response.status = meta['response']['status'].values.map(&:to_s)
          response.base_uri = URI.parse(meta['request']['uri'])
        end
      end
    end
  end
end
