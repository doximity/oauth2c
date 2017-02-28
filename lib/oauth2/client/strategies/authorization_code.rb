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
          def initialize(callback_params)
            @callback_params = callback_params
          end

          def grant_type
            "authorization_code"
          end

          def extra_params
            { code: @callback_params["code"] }
          end
        end
      end
    end
  end
end
