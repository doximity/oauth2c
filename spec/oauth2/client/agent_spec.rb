require "spec_helper"

RSpec.describe OAuth2::Client::Agent do
  subject do
    described_class.new("http://authz.test", "CLIENT_ID", "CLIENT_SECRET")
  end

  let :strategy do
    object_double(OAuth2::Client::Strategy.new)
  end

  it "generates an authorization url for a strategy that supports it" do
    expected_params = {
      response_type: nil,
      client_id: "CLIENT_ID",
      redirect_uri: "http://client.test",
      scope: "basic email",
      state: "DVX0",
    }

    expect(strategy).to receive(:authorize_params)
      .with(expected_params)
      .and_return(expected_params.merge(response_type: "custom"))

    url = nil
    expect {
      url = subject.authorize_url(strategy, redirect_uri: "http://client.test", scope: ["basic", "email"], state: "DVX0")
    }.to_not raise_error

    expect(url).to eq("http://authz.test/oauth/authorize?response_type=custom&client_id=CLIENT_ID&redirect_uri=http%3A%2F%2Fclient.test&scope=basic+email&state=DVX0")
  end
end
