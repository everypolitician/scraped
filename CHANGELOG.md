# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## 0.4.0 - 2017-01-10

### Changed

- The AbsoluteUrls decorator has been renamed to CleanUrls.

## 0.3.0 - 2017-01-10

### Changed

- The AbsoluteUrls decorator now ensures the URL is correctly encoded
  (e.g. by transforming spaces into %20)

## 0.2.0 - 2017-01-04

### Changed

- The logic that was in the `Scraped` class is now in `Scraped::Document`.
- `Scraped::HTML` now inherits from `Scraped::Document` rather than `Scraped`.
- The top level `Scraped` constant is now a `module` instead of a `class`.

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
