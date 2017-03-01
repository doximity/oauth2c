module OAuth2
  module Client
    module Strategies
      module Implicit
        class AuthzHandler < OAuth2::Client::AuthzHandler
          def response_type
            "token"
          end
        end
      end
    end
  end
end
