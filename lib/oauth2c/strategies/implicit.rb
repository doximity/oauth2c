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
    class Implicit < OAuth2c::ThreeLegged::Base
      using Refinements

      def token(callback_url)
        super(callback_url) do |_, fragment_params|
          AccessToken.new(**fragment_params)
        end
      end

      protected

      def authz_params
        { response_type: "token" }
      end
    end
  end
end
