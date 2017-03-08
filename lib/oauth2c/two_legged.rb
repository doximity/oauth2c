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
  module TwoLegged
    class Base
      def initialize(agent, scope: [])
        @agent = agent
        @scope = scope
      end

      def token
        ok, response = @agent.token({ **token_params, scope: @scope })
        handle_token_response(ok, response)
      end

      protected

      def token_params
        raise NotImplementedError
      end

      def handle_token_response(ok, response)
        if ok
          AccessToken.new(**response.symbolize_keys)
        else
          raise Error.new(response["error"], response["error_description"])
        end
      end
    end
  end
end
