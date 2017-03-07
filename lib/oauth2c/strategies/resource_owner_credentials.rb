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
  module Strategies
    class ResourceOwnerCredentials < OAuth2c::TwoLegged::Base
      def initialize(client, username:, password:)
        super(client)
        @username = username
        @password = password
      end

      protected

      def token_params
        { grant_type: "password", username: @username, password: @password }
      end
    end

    # module ResourceOwnerCredentials
    #   class TokenHandler < OAuth2c::TokenHandler
    #     def initialize(username, password)
    #       @username = username
    #       @password = password
    #     end

    #     def grant_type
    #       "password"
    #     end

    #     def extra_params
    #       { username: @username, password: @password }
    #     end
    #   end
    # end
  end
end
