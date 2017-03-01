module OAuth2
  module Client
    module Strategies
      module AuthorizationCode
        class AuthzHandler < OAuth2::Client::AuthzHandler
          def response_type
            "code"
          end
        end

        class TokenHandler < OAuth2::Client::TokenHandler
          def self.from_authz_callback_params(params)
            new(params["code"])
          end

          def initialize(code)
            @code = code
          end

          def grant_type
            "authorization_code"
          end

          def extra_params
            { code: @code }
          end
        end
      end
    end
  end
end
