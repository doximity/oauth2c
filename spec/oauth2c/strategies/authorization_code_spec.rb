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

RSpec.describe OAuth2c::Strategies::AuthorizationCode do
  subject do
    described_class.new(agent, "STATE")
  end

  let :agent do
    instance_double(OAuth2c::Agent)
  end

  let :url do
    "http://resourceowner.test/callback?code=CODE&state=STATE"
  end

  it "generates authz url" do
    expect(agent).to receive(:authz_url).with(
      response_type: "code",
      state: "STATE",
      scope: [],
    ).and_return(url)

    expect(subject.authz_url).to eq(url)
  end

  it "issues a token from the URL" do
    token = OAuth2c::AccessToken.new(
      access_token: "ACCESS_TOKEN",
      token_type: "bearer",
      expires_in: 3600,
      refresh_token: "REFRESH_TOKEN",
    )

    expect(agent).to receive(:token).with(
      grant_type: "authorization_code",
      code: "CODE",
    ).and_return(token)

    expect(subject.token(url)).to eq(token)
  end
end
