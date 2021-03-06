# Copyright 2017 Doximity, Inc. <support@doximity.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "uri"
require "http"
require "json"

module OAuth2c
  class Agent
    using Refinements

    ConfigError = Class.new(StandardError)

    def initialize(authz_url: nil, token_url:, client_id:, client_secret: nil,
                   redirect_uri: nil, client_credentials_on_body: false)
      @authz_url     = authz_url && authz_url.chomp("/")
      @token_url     = token_url && token_url.chomp("/")
      @client_id     = client_id
      @client_secret = client_secret
      @redirect_uri  = redirect_uri
      @client_credentials_on_body = client_credentials_on_body

      @http_client = HTTP.nodelay
        .accept("application/json")
        .headers(
          "Content-Type": "application/x-www-form-urlencoded; encoding=UTF-8",
          "User-Agent": user_agent_header
        )
      unless @client_credentials_on_body
        @http_client = @http_client.basic_auth(user: @client_id, pass: @client_secret)
      end
    end

    def user_agent_header
      gem_name = "oauth2c"
      gem_version = OAuth2c::VERSION
      app_name = ENV.fetch("APP_NAME", nil) # rubocop:disable Env/OutsideConfig, Env/UndefinedVar
      formatted_app_name = (app_name ? " (#{app_name})" : "")

      "#{gem_name}/#{gem_version}#{formatted_app_name}"
    end

    def authz_url(response_type:, state:, scope: [], **params)
      if @authz_url.nil?
        raise ConfigError, "authz_url not informed for client"
      end

      if @redirect_uri.nil?
        raise ConfigError, "redirect_uri not informed for client"
      end

      params = {
        client_id: @client_id,
        redirect_uri: @redirect_uri,
        response_type: response_type,
        state: state,
        scope: normalize_scope(scope),
        **params
      }

      url = URI.parse(@authz_url)
      url.query = URI.encode_www_form(params.to_a)
      url.to_s
    end

    def token(grant_type:, scope: [], include_redirect_uri: false, **params)
      params = {
        grant_type: grant_type,
        scope: normalize_scope(scope),
        **params,
      }
      if @client_credentials_on_body
        params.merge!(
          client_id: @client_id,
          client_secret: @client_secret
        )
      end

      if include_redirect_uri
        params[:redirect_uri] = @redirect_uri
      end

      response = @http_client.post(@token_url, body: URI.encode_www_form(params))

      [ response.status.success?, JSON.parse(response.body) ]
    end

    private

    def normalize_scope(scope)
      case scope
      when "", [], NilClass
        nil
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
