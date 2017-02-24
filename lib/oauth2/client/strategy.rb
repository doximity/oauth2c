module OAuth2
  module Client
    class Strategy
      def authorize_params(params)
        params
      end

      def token_params(params)
        params
      end
    end
  end
end
