module OAuth2c
  module Strategies
    autoload :AuthorizationCode,        "oauth2c/strategies/authorization_code"
    autoload :ClientCredentials,        "oauth2c/strategies/client_credentials"
    autoload :Implicit,                 "oauth2c/strategies/implicit"
    autoload :ResourceOwnerCredentials, "oauth2c/strategies/resource_owner_credentials"
  end
end
