## 1.1.0 - 12/16/2019
  * Set User-Agent header on agent requests

## 1.0.0 - 01/28/2019
  * Allow newer http gem dependency (#3)
  * Drop support for Ruby 2.2 and earlier

## 0.3.0 - 09/21/2017
  * Allow doing auth over body params, instead of basic auth (header) (#1)

## 0.2.1 - 04/18/2017
  * Fix issue JWT with nbf claim one second in the past

## 0.2.0 - 04/14/2017
  * Update README with list of cache backends
  * Fix manager delegate for client attrs
  * Add support for default_scope
  * Fix manager call to cache layer
  * Don't cache with nil key
  * Fix RefreshToken and ResourceOwnerCredentials initializer
  * Only cache token when key is not nil
  * Return nil from cached, not false
  * Add exp leeway to cache expiration
  * Dynamically define methods for OAuth2c::Client
  * Define respond_to_missing? for OAuth2::Cache::Manager
  * Allow three legged token method to receive hash with params
  * Allow expires_at to be set on access token
  * Add expired? with leeway support to AccessToken
  * Define comparison operator for AccessToken to return false for other class
  * Properly convert time for access token to handle serialization


## 0.1.0 - 03/10/2017
  * Initial release
