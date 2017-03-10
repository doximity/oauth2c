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

RSpec.describe OAuth2c::Cache::Manager do
  subject do
    described_class.new(client, backend)
  end

  let :client do
    double(:client)
  end

  let :backend do
    OAuth2c::Cache::Backends::InMemoryLRU.new(5)
  end

  let :access_token do
    instance_double(OAuth2c::AccessToken)
  end

  it "wraps cache and delegates to grant" do
    key   = "key"
    scope = ["basic"]

    expect(subject.cached?(key, scope: scope)).to be_falsy

    grant = double(:grant, token: access_token, scope: scope)
    expect(grant).to receive(:update_scope).with(scope)

    expect(client).to receive(:a_strategy_name).with(scope: scope).and_return(grant)
    returned_grant = subject.a_strategy_name(key, scope: scope)
    expect(returned_grant.token).to eq(access_token)
  end
end
