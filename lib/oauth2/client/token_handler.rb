module OAuth2
  module Client
    class TokenHandler
      def grant_type
        raise NotImplementedError
      end

      def extra_params
        {}
      end
    end
  end
end
