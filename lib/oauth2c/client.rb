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

    def initialize(authz_url: nil, token_url:, client_id:, client_secret: nil,
                   redirect_uri: nil, default_scope: [], agent_options: {})
      @authz_url     = authz_url
      @token_url     = token_url
      @client_id     = client_id
      @client_secret = client_secret
      @redirect_uri  = redirect_uri
      @default_scope = default_scope
      @agent_options = agent_options

      define_grant_methods!
    end

    private

    def define_grant_methods!
      Grants.constants.each do |name|
        const = Grants.const_get(name)

        define_singleton_method("#{name.to_s.underscore}") do |*_, scope: @default_scope, **opts|
          const.new(build_agent, scope: scope, **opts)
        end
      end
    end

    def build_agent
      Agent.new(
        authz_url: @authz_url,
        token_url: @token_url,
        client_id: @client_id,
        client_secret: @client_secret,
        redirect_uri: @redirect_uri,
        **@agent_options
      )
    end
  end
end
