module OAuth2c
  class TokenHandler
    def grant_type
      raise NotImplementedError
    end

    def extra_params
      {}
    end
  end
end
