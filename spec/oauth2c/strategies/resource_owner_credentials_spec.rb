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

RSpec.describe OAuth2c::Strategies::ResourceOwnerCredentials do
  subject do
    described_class.new(client, "username", "password")
  end

  let :client do
    instance_double(OAuth2c::Client)
  end

  it "performs request to token endpoint" do
    access_token = double(:access_token)

    expect(client).to receive(:token).with(
      grant_type: "password",
      username: "username",
      password: "password",
      scope: [],
    ).and_return(access_token)

    expect(subject.token).to eq(access_token)
  end
end
