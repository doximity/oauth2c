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
  class Client
    ConfigError = Class.new(StandardError)

    def initialize(authz_url: nil, token_url:, client_id:, client_secret: nil, redirect_uri: nil)
      @authz_url     = authz_url && authz_url.chomp("/")
      @token_url     = token_url && token_url.chomp("/")
      @client_id     = client_id
      @client_secret = client_secret
      @redirect_uri  = redirect_uri

      @http_client = HTTP.nodelay
        .basic_auth(user: @client_id, pass: @client_secret)
        .accept("application/json")
        .headers("Content-Type": "application/x-www-form-urlencoded; encoding=UTF-8")
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

    def token(grant_type:, scope: [], **params)
      params = {
        grant_type: grant_type,
        scope: normalize_scope(scope),
        **params,
      }

      response = @http_client.post(@token_url, body: URI.encode_www_form(params))

      if response.status.success?
        AccessToken.new(JSON.parse(response.body))
      else
        json = JSON.parse(response.body)
        raise Error.new(json["error"], json["error_description"])
      end
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
