# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'scraped_page/version'

Gem::Specification.new do |spec|
  spec.name          = "scraped_page"
  spec.version       = ScrapedPage::VERSION
  spec.authors       = ["EveryPolitician"]
  spec.email         = ["team@everypolitician.org"]

  spec.summary       = %q{Write declarative scrapers in Ruby}
  spec.homepage      = "https://github.com/everypolitician/scraped_page"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rubocop", "~> 0.44"
end
