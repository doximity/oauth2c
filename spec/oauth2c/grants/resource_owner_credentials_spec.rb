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

RSpec.describe OAuth2c::Grants::ResourceOwnerCredentials do
  subject do
    described_class.new(agent, username: "username", password: "password")
  end

  let :agent do
    instance_double(OAuth2c::Agent)
  end

  it "performs request to token endpoint" do
    token_payload = {
      access_token: "ACCESS_TOKEN",
      token_type: "bearer",
      expires_in: 3600,
      refresh_token: "REFRESH_TOKEN",
    }

    expect(agent).to receive(:token).with(
      grant_type: "password",
      username: "username",
      password: "password",
      scope: [],
    ).and_return([ true, token_payload ])

    expect(subject.token).to eq(OAuth2c::AccessToken.new(token_payload))
  end
end
