module OAuth2c
  class AccessToken
    attr_reader(
      :access_token,
      :token_type,
      :expires_in,
      :expires_at,
      :refresh_token,
      :extra_params,
    )

    def initialize(attrs)
      attrs = attrs.dup

      @access_token  = attrs.delete("access_token")
      @token_type    = attrs.delete("token_type")
      @expires_in    = attrs.delete("expires_in")
      @refresh_token = attrs.delete("refresh_token")
      @extra_params  = attrs

      @expires_at = (Time.respond_to?(:zone) ? Time.zone.now : Time.now) + @expires_in
    end

    def attributes
      {
        access_token: @access_token,
        token_type: @token_type,
        expires_in: @expires_in,
        expires_at: @expires_at,
        refresh_token: @refresh_token,
        extra_params: @extra_params,
      }
    end
  end
end
