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
  module Grants
    class AuthorizationCode < ThreeLegged::Base
      protected

      def authz_params
        { response_type: "code" }
      end

      def token_params(*args, code:, **_)
        { grant_type: "authorization_code", code: code }
      end
    end
  end
end
