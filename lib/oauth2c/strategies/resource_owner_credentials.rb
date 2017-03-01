module OAuth2
  module Client
    module Strategies
      module ResourceOwnerCredentials
        class TokenHandler < OAuth2c::TokenHandler
          def initialize(username, password)
            @username = username
            @password = password
          end

          def grant_type
            "password"
          end

          def extra_params
            { username: @username, password: @password }
          end
        end
      end
    end
  end
end
