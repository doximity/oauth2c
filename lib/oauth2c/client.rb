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

module OAuth2c
  class Client
    using Refinements

    attr_reader(
      :authz_url,
      :token_url,
      :client_id,
      :client_secret,
      :redirect_uri,
      :default_scope,
    )

    def initialize(authz_url: nil, token_url:, client_id:, client_secret: nil, redirect_uri: nil, default_scope: [])
      @authz_url     = authz_url
      @token_url     = token_url
      @client_id     = client_id
      @client_secret = client_secret
      @redirect_uri  = redirect_uri
      @default_scope = default_scope
    end

    def method_missing(name, *_, scope: @default_scope, **opts)
      Grants.const_get(name.to_s.camelize).new(build_agent, scope: scope, **opts)
    end

    private

    def build_agent
      Agent.new(
        authz_url: @authz_url,
        token_url: @token_url,
        client_id: @client_id,
        client_secret: @client_secret,
        redirect_uri: @redirect_uri,
      )
    end
  end
end
