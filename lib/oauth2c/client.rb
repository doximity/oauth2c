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

    def initialize(
      authz_url: nil,
      token_url:,
      client_id:,
      client_secret: nil,
      redirect_uri: nil,
      cache_backend: OAuth2c::Cache::Backends::Null.new
    )
      @agent = Agent.new(
        authz_url: authz_url,
        token_url: token_url,
        client_id: client_id,
        client_secret: client_secret,
        redirect_uri: redirect_uri,
      )

      @cache_backend = cache_backend
    end

    def method_missing(name, *args, **opts)
      grant_class = Grants.const_get(name.to_s.camelize)
      grant_class.new(@agent, **opts).with_caching(@cache_backend)
    end
  end
end
