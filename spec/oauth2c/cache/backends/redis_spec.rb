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
require "redis"

RSpec.describe OAuth2c::Cache::Backends::Redis do
  subject do
    described_class.new(redis, 'ns')
  end

  let :redis do
    instance_double(Redis)
  end

  let :access_token do
    OAuth2c::AccessToken.new(
      access_token: "ACCESS_TOKEN",
      token_type: "bearer",
      expires_in: 3600,
    )
  end

  let :access_token_json do
    JSON.dump(access_token.attributes)
  end

  it "sucessfully store and lookup a key" do
    key    = "KEY"
    bucket = OAuth2c::Cache::Store::Bucket.new(access_token, ["basic", "profile"])

    expect(redis).to receive(:mset).with(
      "ns:KEY:access_token", access_token_json,
      "ns:KEY:scope", '["basic","profile"]',
    )
    expect(redis).to receive(:expire).with("ns:KEY:access_token", access_token.expires_in)
    expect(redis).to receive(:expire).with("ns:KEY:scope", access_token.expires_in)
    subject.store(key, bucket)

    expect(redis).to receive(:mget).with("ns:KEY:access_token", "ns:KEY:scope").and_return([access_token_json, '["basic","profile"]'])
    expect(subject.lookup(key)).to eq(bucket)
  end

  it "returns nil for lookup of uncached data" do
    expect(redis).to receive(:mget).with("ns:KEY:access_token", "ns:KEY:scope").and_return([nil, nil])
    expect(subject.lookup("KEY")).to be_nil
  end
end
