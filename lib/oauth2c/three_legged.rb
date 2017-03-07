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
    class Base
      def initialize(client, state)
        @client = client
        @state  = state
      end

      def authz_url
        @client.authz_url(authz_params)
      end

      def token(callback_url)
        uri    = URI.parse(callback_url)
        params = Hash[URI.decode_www_form(uri.query.to_s)]

        token_args = {}
        token_params_keys.each do |key|
          token_args[key] = params[key.to_s]
        end

        @client.token(**token_args)
      end

      protected

      def authz_params
        raise NotImplementedError
      end

      def token_params
        raise NotImplementedError
      end

      def token_params_keys
        return @_token_params_keys if defined?(@_token_params_keys)

        @token_params_keys = method(:token_params).parameters.map do |(type, name)|
          if type == :key || type == :keyreq
            name
          end
        end.compact
      end
    end
  end
end
