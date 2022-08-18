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

require "spec_helper"

RSpec.describe OAuth2c::Grants::Assertion do
  subject do
    described_class.new(agent, profile: profile)
  end

  let :agent do
    instance_double(OAuth2c::Agent)
  end

  context "with JWT profile" do
    let :profile do
      OAuth2c::Grants::Assertion::JWTProfile.new(
        "HS512",
        "MYKEY",
        iss: "http://resourceowner.test",
        aud: "http://authzserver.test",
        sub: "user@test",
        nbf: Time.now - 60,
        iat: Time.now - 60,
      )
    end

    it "performs request to token endpoint" do
      token_payload = {
        access_token: "ACCESS_TOKEN",
        token_type: "bearer",
        expires_in: 3600,
        refresh_token: "REFRESH_TOKEN",
      }

      expect(agent).to receive(:token).with(
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion: JWTMatcher.new("HS512", "MYKEY", profile.claims),
        scope: [],
      ).and_return([ true, token_payload ])

      expect(subject.token).to eq(OAuth2c::AccessToken.new(**token_payload))
    end

    class JWTMatcher
      def initialize(alg, key, *args, **claims)
        @alg = alg
        @key = key
        @claims = claims
      end

      def ==(encoded_jwt)
        decoded = JWT.decode(encoded_jwt, @key, true, {
          algorithm: @alg,
          verify_iss: true,
          verify_aud: true,
          verify_iat: true,
          verify_sub: true,
          verify_jti: true,
          **@claims,
        })

        true
      rescue JWT::ImmatureSignature
        false
      end
    end
  end
end
