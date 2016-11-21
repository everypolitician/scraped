# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scraped/version'

Gem::Specification.new do |spec|
  spec.name          = 'scraped'
  spec.version       = Scraped::VERSION
  spec.authors       = ['EveryPolitician']
  spec.email         = ['team@everypolitician.org']

  spec.summary       = 'Write declarative scrapers in Ruby'
  spec.homepage      = 'https://github.com/everypolitician/scraped'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'field_serializer'
  spec.add_runtime_dependency 'scraped_page_archive', '>= 0.5'

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rubocop', '~> 0.44'
end
