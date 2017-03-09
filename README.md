# OAuth2c

OAuth2c is a safe and extensible OAuth2 client implementation. The goal of this project is provide a client with a standard simple interface that abstracts some of the implementation details while keeping it flexible and extensible for new grant types.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oauth2c'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oauth2-client

## Usage

Instantiate a `OAuth2c::Client` instance with the application configuration issued by the authorization server. This can be instantiated once per-app and kept around for the entire lifetime of it In case of a Rails application, it's recommended to do it once inside a initializer:

```ruby
OAUTH2C_CLIENT = OAuth2c::Client.new(
  authz_url:     "https://authorization-server.example/oauth/authorize",
  token_url:     "https://authorization-server.example/oauth/token",
  client_id:     "APP_CLIENT_ID",
  client_secret: "APP_CLIENT_SECRET",
  redirect_uri:  "https://myapp.com/oauth2callback",
)
```

In order to issue an access token, you need to pick one of the grant type available. Note that not all grant types might be implemented on the server side nor be allowed for your client.

This gem ships with following grant types:

* [Authorization Code Grant](#authorization-code-grant) [[RFC6749](https://tools.ietf.org/html/rfc6749)]
* [Implicit Grant](#implicit-grant) [[RFC6749](https://tools.ietf.org/html/rfc6749)]
* [Resource Owner Password Credentials Grant](#resource-owner-password-credentials-grant) [[RFC6749](https://tools.ietf.org/html/rfc6749)]
* [Client Credentials Grant](#client-credentials-grant) [[RFC6749](https://tools.ietf.org/html/rfc6749)]
* [Assertion Grant w/ JWT Profile Support](#assertion-grant-w-jwt-profile-support) [[RFC7521](https://tools.ietf.org/html/rfc7521) / [RFC7523](https://tools.ietf.org/html/rfc7523)]

### Authorization Code Grant

As described by https://tools.ietf.org/html/rfc6749#section-4.1, the client generates a URL and redirects the user-agent it:

```ruby
grant = OAUTH2C_CLIENT.authorization_code(state: "STATE", scope: ["profile", "email"])
redirect_to grant.authorize_url
```

Under the client's redirect_uri handler, the client needs to read the parameters included in the URL and exchange the information, in this case the code, for a token. The gem takes care of it and parses the necessary information directly from the URL.

```ruby
grant = OAUTH2C_CLIENT.authorization_code(state: "STATE", scope: ["profile", "email"])
grant.token(url)
```

### Implicit Flow

As described by https://tools.ietf.org/html/rfc6749#section-4.2, the client generates a URL and redirects the user-agent it:

```ruby
grant = OAUTH2C_CLIENT.implicit(state: "STATE", scope: ["profile", "email"])
redirect_to grant.authorize_url
```

Under the client's redirect_uri handler, the client needs to read the fragment (after # sign) included in the URL and initialize the token from it. The gem takes care of it and parses the necessary information directly from the URL.

```ruby
grant = OAUTH2C_CLIENT.implicit(state: "STATE", scope: ["profile", "email"])
grant.token(url)
```

NOTE: keep in mind that if the request is being made from a web browser, the fragment is usally stripped away from the URL sent to the server. For this reason, this strategy is not very useful for server side components but can be useful for native apps built with ruby where you have full control over the user-agent.

### Resource Owner Password Credentials Grant

As described by https://tools.ietf.org/html/rfc6749#section-4.3, the client collects the username and password and exchange it by a token:

```ruby
grant = OAUTH2C_CLIENT.resource_owner_credentials(username: 'user@example.com', password: 'secret',
  scope: ["profile", "email"])
grant.token
```

### Client Credentials Grant

As described by https://tools.ietf.org/html/rfc6749#section-4.4, the client issues a token on behalf of itself instead of an user:

```ruby
grant = OAUTH2C_CLIENT.client_credentials(scope: ["profile", "email"])
grant.token
```

### Assertion Grant w/ JWT Profile Support

As described by https://tools.ietf.org/html/rfc7521 and https://tools.ietf.org/html/rfc7523, the client issues a token on behalf of user without requiring the user approval. Instead, the client provides a assertion with the information about the user.

```ruby
profile = OAuth2c::Grants::Assertion::JWT.new(
  "HS512",
  "assertion-key",
  iss: "https://myapp.example",
  aud: "https://authorization-server.example",
  sub: "user@example.com",
)

grant = OAUTH2C_CLIENT.assertion(profile: profile, scope: ["profile", "email"])
grant.token
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/doximity/oauth2c. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.
