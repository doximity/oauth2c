module OAuth2
  module Client
    module Strategies
      autoload :AuthorizationCode,        "oauth2/client/strategies/authorization_code"
      autoload :ClientCredentials,        "oauth2/client/strategies/client_credentials"
      autoload :Implicit,                 "oauth2/client/strategies/implicit"
      autoload :ResourceOwnerCredentials, "oauth2/client/strategies/resource_owner_credentials"
    end
  end
end
