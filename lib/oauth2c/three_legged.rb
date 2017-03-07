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
  module ThreeLegged
    using Refinements

    class Base
      def initialize(agent, state, scope: [])
        @agent = agent
        @state  = state
        @scope  = scope
      end

      def authz_url
        @agent.authz_url(state: @state, scope: @scope, **authz_params)
      end

      def token(callback_url)
        query_params, _ = parse_callback_url(callback_url)
        @agent.token(**token_params(query_params))
      end

      protected

      def authz_params
        raise NotImplementedError
      end

      def token_params
        raise NotImplementedError
      end

      def parse_callback_url(callback_url)
        uri = URI.parse(callback_url)

        query_params    = Hash[URI.decode_www_form(uri.query.to_s)].symbolize_keys
        fragment_params = Hash[URI.decode_www_form(uri.fragment.to_s)].symbolize_keys

        [query_params, fragment_params]
      end
    end
  end
end
