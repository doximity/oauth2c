require "uri"

module OAuth2
  module Client
    class Agent
      def initialize(authz_url, client_id, client_secret)
        @authz_url     = URI.parse(authz_url)
        @client_id     = client_id
        @client_secret = client_secret
      end

      def authorize_url(strategy, redirect_uri:, scope:, state: nil)
        params = strategy.authorize_params(
          response_type: nil,
          client_id: @client_id,
          redirect_uri: redirect_uri,
          scope: normalize_scope(scope),
          state: state,
        )

        url = @authz_url.dup
        url.path.chomp!("/")
        url.path << "/oauth/authorize"
        url.query = URI.encode_www_form(params.to_a)
        url.to_s
      end

      private

      def normalize_scope(scope)
        case scope
        when String
          scope
        when Array
          scope.join(" ")
        else
          raise ArgumentError, "invalid scope: #{scope.inspect}"
        end
      end
    end
  end
end
