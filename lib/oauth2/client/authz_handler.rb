module OAuth2
  module Client
    class AuthzHandler
      def response_type
        raise NotImplementedError
      end

      def extra_params
        {}
      end
    end
  end
end
