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

RSpec.describe OAuth2c::Cache::Store do
  subject do
    described_class.new(backend)
  end

  let :backend do
    OAuth2c::Cache::Backends::InMemoryLRU.new(5)
  end

  let :access_token do
    instance_double(OAuth2c::AccessToken, expires_at: Time.now + 3600)
  end

  it "caches a access token when issued" do
    key   = "user@example.com"
    scope = ["basic"]

    # first attempt should not be cached
    expect(subject.cached?(key, scope: scope)).to be_falsy

    # Then we issue an access token
    issued_access_token = subject.issue(key, scope: scope) do |new_scope|
      expect(new_scope).to eq(new_scope)
      access_token
    end

    expect(issued_access_token).to eq(access_token)

    # Expect it to be cached now
    expect(subject.cached?(key, scope: scope)).to be_truthy
    expect(subject.cached(key, scope: scope)).to eq(access_token)
  end

  it "reissue token with incremented set of scopes" do
    key = "user@example.com"

    # issue first token
    issued_access_token = subject.issue(key, scope: ["basic"]) do |new_scope|
      expect(new_scope).to eq(["basic"])
      access_token
    end
    expect(issued_access_token).to eq(access_token)

    # it's not cached for a incremented set of scopes
    expect(subject.cached?(key, scope: ["basic", "profile"])).to be_falsy

    # issue a new token with new scope set
    issued_access_token = subject.issue(key, scope: ["basic", "profile"]) do |new_scope|
      expect(new_scope).to eq(["basic", "profile"])
      access_token
    end
    expect(issued_access_token).to eq(access_token)

    expect(subject.cached?(key, scope: ["basic", "profile"])).to be_truthy
    expect(subject.cached(key, scope: ["basic", "profile"])).to eq(access_token)
  end

  it "reissue token with union of scopes when diverging scopes are presented" do
    key = "user@example.com"

    # issue first token
    issued_access_token = subject.issue(key, scope: ["basic"]) do |new_scope|
      expect(new_scope).to eq(["basic"])
      access_token
    end
    expect(issued_access_token).to eq(access_token)

    # it's not cached for a diverging set of scopes
    expect(subject.cached?(key, scope: ["profile"])).to be_falsy

    # issue a new token with union set
    issued_access_token = subject.issue(key, scope: ["basic", "profile"]) do |new_scope|
      expect(new_scope).to eq(["basic", "profile"])
      access_token
    end
    expect(issued_access_token).to eq(access_token)

    expect(subject.cached?(key, scope: ["basic", "profile"])).to be_truthy
    expect(subject.cached(key, scope: ["basic", "profile"])).to eq(access_token)
  end

  it "subset of scope is considered cache" do
    key = "user@example.com"

    issued_access_token = subject.issue(key, scope: ["basic", "profile"]) do |new_scope|
      expect(new_scope).to eq(["basic", "profile"])
      access_token
    end
    expect(issued_access_token).to eq(access_token)
    expect(subject.cached?(key, scope: ["basic"])).to be_truthy
    expect(subject.cached?(key, scope: ["profile"])).to be_truthy
    expect(subject.cached?(key, scope: [])).to be_truthy
  end

  it "doesn't considered expired tokens cached" do
    key = "user@example.com"

    issued_access_token = subject.issue(key, scope: ["basic"]) do |new_scope|
      expect(new_scope).to eq(["basic"])
      access_token
    end

    allow(access_token).to receive(:expires_at).and_return(Time.now - 1)
    expect(subject.cached?(key, scope: ["basic"])).to be_falsy
  end

  it "doesn't cache when key is nil" do
    key = nil

    issued_access_token = subject.issue(key, scope: ["basic"]) do |new_scope|
      expect(new_scope).to eq(["basic"])
      access_token
    end

    expect(subject.cached?(key, scope: ["basic"])).to be_falsy
  end
end
