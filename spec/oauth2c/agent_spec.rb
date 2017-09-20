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

RSpec.describe OAuth2c::Agent do
  subject do
    described_class.new(
      authz_url: "http://authz.test/oauth/authorize",
      token_url: "http://authz.test/oauth/token",
      client_id: "CLIENT_ID",
      client_secret: "CLIENT_SECRET",
      redirect_uri: "http://client.test/callback",
    )
  end

  it "generates an authorization url for a strategy that supports it" do
    url = subject.authz_url(response_type: "custom", state: "DVX0", scope: ["basic", "email"])
    expect(url).to eq("http://authz.test/oauth/authorize?client_id=CLIENT_ID&redirect_uri=http%3A%2F%2Fclient.test%2Fcallback&response_type=custom&state=DVX0&scope=basic+email")
  end

  it "fetches a token based on the strategy" do
    stub_request(:post, "http://authz.test/oauth/token")
      .with(
        body: "grant_type=custom&scope=basic+email&custom_code=123",
        headers: { "Accept": "application/json", "Authorization": "Basic Q0xJRU5UX0lEOkNMSUVOVF9TRUNSRVQ=", "Content-Type": "application/x-www-form-urlencoded; encoding=UTF-8" }
      )
      .to_return(
        status: 200,
        headers: { "Content-Type": "application/json; encoding=utf-8" },
        body: JSON.dump(
          access_token: "2YotnFZFEjr1zCsicMWpAA",
          token_type: "Bearer",
          expires_in: 3600,
          refresh_token: "tGzv3JOkF0XG5Qx2TlKWIA",
          example_parameter: "example_value",
        ),
      )

    ok, token = subject.token(grant_type: "custom", custom_code: "123", scope: ["basic", "email"])
    expect(ok).to be_truthy

    expect(token["access_token"]).to eq("2YotnFZFEjr1zCsicMWpAA")
    expect(token["token_type"]).to eq("Bearer")
    expect(token["expires_in"]).to eq(3600)
    expect(token["refresh_token"]).to eq("tGzv3JOkF0XG5Qx2TlKWIA")
    expect(token["example_parameter"]).to eq("example_value")
  end

  it "allows passing auth via the body" do
    stub_response = double(
      status: double(success?: true),
      headers: { "Content-Type": "application/json; encoding=utf-8" },
      body: JSON.dump({})
    )
    required_args = { token_url: "http://example.com/token", client_id: "id" }
    agent = described_class.new(client_credentials_on_body: true, client_secret: "secret",
                                **required_args)
    expected_body = "grant_type=foo&scope&client_id=id&client_secret=secret"
    expect_any_instance_of(HTTP::Client).to receive(:post).
      with(anything, hash_including(body: expected_body)).
      and_return(stub_response)
    agent.token(grant_type: "foo")
  end
end
