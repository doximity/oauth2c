module OAuth2
  module Client
    module Strategies
      module ClientCredentials
        class TokenHandler < OAuth2::Client::AuthzHandler
          def grant_type
            "client_credentials"
          end
        end
      end
    end
  end
end
