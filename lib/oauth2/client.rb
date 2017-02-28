module OAuth2
  module Client
    autoload :AccessToken,  "oauth2/client/access_token"
    autoload :Agent,        "oauth2/client/agent"
    autoload :AuthzHandler, "oauth2/client/authz_handler"
    autoload :Strategies,   "oauth2/client/strategies"
    autoload :TokenHandler, "oauth2/client/token_handler"
    autoload :VERSION,      "oauth2/client/version"
  end
end
