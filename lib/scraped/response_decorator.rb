module Scraped
  class ResponseDecorator
    def initialize(response:, decorators:)
      @original_response = response
      @decorators = decorators.to_a
    end

    def response
      decorators.reduce(original_response) do |r, decorator_config|
        unless decorator_config.respond_to?(:[])
          decorator_config = { decorator: decorator_config }
        end
        decorator_class = decorator_config[:decorator]
        decorator_class.new(response: r, config: decorator_config)
                       .decorated_response
      end
    end

    private

    attr_reader :original_response, :decorators
  end
end
