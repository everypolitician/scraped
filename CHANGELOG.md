# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 0.1.0 - 2017-01-04

### Added

- Support for creating HTML scrapers.
- Scraper classes can handle sections of a page.
- Custom request logic via request strategies. This could be used to fetch
  responses from an archive or a local cache.
- Custom response decorators for altering the response status, headers and body
  before it gets to the scraper class.
- Built-in response decorator for making link and image urls absolute.
- `String#tidy` method which cleans up various space characters and then strips
  leading and trailing whitespace.
