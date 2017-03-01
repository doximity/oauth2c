require "uri"
require "http"
require "json"

module OAuth2c
  class Agent
    def initialize(authz_srv_url, client_id, client_secret)
      @authz_srv_url = URI.parse(authz_srv_url.chomp("/"))
      @client_id     = client_id
      @client_secret = client_secret

      @http_client = HTTP.nodelay
        .basic_auth(user: @client_id, pass: @client_secret)
        .accept("application/json")
        .headers("Content-Type": "application/x-www-form-urlencoded; encoding=UTF-8")
    end

    def authz_url(authz_handler, redirect_uri:, scope:, state: nil)
      params = {
        response_type: authz_handler.response_type,
        client_id: @client_id,
        redirect_uri: redirect_uri,
        scope: normalize_scope(scope),
        state: state,
        **authz_handler.extra_params,
      }

      url = @authz_srv_url.dup
      url.path  = "#{url.path}/authorize"
      url.query = URI.encode_www_form(params.to_a)
      url.to_s
    end

    def token(token_handler, redirect_uri: nil)
      params = {
        grant_type: token_handler.grant_type,
        **token_handler.extra_params,
      }

      unless redirect_uri.nil?
        params[:redirect_uri] = redirect_uri
      end

      response = @http_client.post("#{@authz_srv_url}/token", body: URI.encode_www_form(params))

      if response.status.success?
        AccessToken.new(JSON.parse(response.body))
      else
        puts response.body
      end
    end

    private

    def normalize_scope(scope)
      case scope
      when String
        scope
      when Array
        scope.join(" ")
      when NilClass
        []
      else
        raise ArgumentError, "invalid scope: #{scope.inspect}"
      end
    end
  end
end
