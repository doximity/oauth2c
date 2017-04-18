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

require "securerandom"
require "jwt"

module OAuth2c
  module Grants
    class Assertion < OAuth2c::TwoLegged::Base
      class JWTProfile
        def initialize(alg, key,
            iss:,
            aud:,
            sub:,
            jti: SecureRandom.uuid,
            exp: Time.now + (5 * 60),
            nbf: Time.now - 1,
            iat: Time.now,
            **other_claims
        )
          @alg = alg
          @key = key

          @iss = iss
          @aud = aud
          @sub = sub
          @jti = jti
          @exp = exp
          @nbf = nbf
          @iat = iat

          @other_claims = other_claims
        end

        def grant_type
          "urn:ietf:params:oauth:grant-type:jwt-bearer"
        end

        def assertion
          JWT.encode(claims, @key, @alg)
        end

        def claims
          {
            iss: @iss,
            sub: @sub,
            aud: @aud,
            jti: @jti,
            exp: @exp && @exp.utc.to_i,
            nbf: @nbf && @nbf.utc.to_i,
            iat: @iat && @iat.utc.to_i,
            **@other_claims,
          }
        end
      end

      def initialize(agent, profile:, **opts)
        super(agent, **opts)
        @profile = profile
      end

      protected

      def token_params
        { grant_type: @profile.grant_type, assertion: @profile.assertion }
      end
    end
  end
end
