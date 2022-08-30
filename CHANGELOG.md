# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0.pre.1] - 2022-08-19
- Add support for ruby3/ruby 2.7

## [1.1.2] - 2020-02-24
### Changed
- Release on RubyGems using gem-publisher CircleCI Orb
- Build doc and make it available on CircleCI's build artifacts
- Packing gems

## [1.1.1] 2020-01-16
### Changed
- Removed doximity references from code

## [1.1.0] - 2019-12-16
### Added
- Set User-Agent header on agent requests

## [1.0.0] - 2019-01-28
### Changed
- Allow newer http gem dependency (#3)
- Drop support for Ruby 2.2 and earlier

## [0.3.0] - 2017-09-21
### Changed
- Allow doing auth over body params, instead of basic auth (header) (#1)

## [0.2.1] - 2017-04-18
### Changed
- Fix issue JWT with nbf claim one second in the past

## [0.2.0] - 2017-04-14
- Update README with list of cache backends
- Fix manager delegate for client attrs
- Add support for default_scope
- Fix manager call to cache layer
- Don't cache with nil key
- Fix RefreshToken and ResourceOwnerCredentials initializer
- Only cache token when key is not nil
- Return nil from cached, not false
- Add exp leeway to cache expiration
- Dynamically define methods for OAuth2c::Client
- Define respond_to_missing? for OAuth2::Cache::Manager
- Allow three legged token method to receive hash with params
- Allow expires_at to be set on access token
- Add expired? with leeway support to AccessToken
- Define comparison operator for AccessToken to return false for other class
- Properly convert time for access token to handle serialization

## [0.1.0] - 2017-03-10
- Initial release
