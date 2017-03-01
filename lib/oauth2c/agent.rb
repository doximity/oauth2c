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
    def initialize(authz_url, token_url, client_id, client_secret)
      @authz_url = authz_url.chomp("/")
      @token_url = token_url.chomp("/")

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

      url = URI.parse(@authz_url)
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
