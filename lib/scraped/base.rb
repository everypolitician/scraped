# frozen_string_literal: true
require 'nokogiri'
require 'field_serializer'

class Scraped
  # Abstract class which scrapers can extend to implement their functionality.
  class Base
    include FieldSerializer

    def self.decorator(klass, config = {})
      decorators << config.merge(decorator: klass)
    end

    def self.decorators
      @decorators ||= []
    end

    def self.inherited(klass)
      klass.decorators.concat(decorators)
      super
    end

    def initialize(response:)
      @original_response = response
    end

    private

    attr_reader :original_response

    def response
      @response ||= ResponseDecorator.new(
        response:   original_response,
        decorators: self.class.decorators
      ).response
    end

    def url
      response.url
    end
  end
end
