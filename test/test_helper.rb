$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'scraped'

require 'minitest/around/spec'
require 'minitest/autorun'
require 'vcr'
require 'webmock'

VCR.configure do |c|
  c.cassette_library_dir = 'test/cassettes'
  c.hook_into :webmock
end
