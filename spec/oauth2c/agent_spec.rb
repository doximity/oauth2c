require "spec_helper"

RSpec.describe OAuth2c::Agent do
  subject do
    described_class.new("http://authz.test/oauth", "CLIENT_ID", "CLIENT_SECRET")
  end

  class CustomStrategy
    class AuthzHandler
      def response_type
        "custom"
      end

      def extra_params
        { custom: "foobar" }
      end
    end

    class TokenHandler
      def initialize(callback_params)
        @callback_params = callback_params
      end

      def grant_type
        "custom"
      end

      def extra_params
        { custom_code: @callback_params[:custom_code] }
      end
    end
  end

  let :authz_handler do
    CustomStrategy::AuthzHandler.new
  end

  let :token_handler do
    CustomStrategy::TokenHandler.new(custom_code: "123")
  end

  it "generates an authorization url for a strategy that supports it" do
    url = subject.authz_url(authz_handler, redirect_uri: "http://client.test", scope: ["basic", "email"], state: "DVX0")
    expect(url).to eq("http://authz.test/oauth/authorize?response_type=custom&client_id=CLIENT_ID&redirect_uri=http%3A%2F%2Fclient.test&scope=basic+email&state=DVX0&custom=foobar")
  end

  it "fetches a token based on the strategy" do
    stub_request(:post, "http://authz.test/oauth/token")
      .with(
        body: "grant_type=custom&custom_code=123",
        headers: { "Accept": "application/json", "Authorization": "Basic Q0xJRU5UX0lEOkNMSUVOVF9TRUNSRVQ=", "Content-Type": "application/x-www-form-urlencoded; encoding=UTF-8"}
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

    token = subject.token(token_handler)
    expect(token.access_token).to eq("2YotnFZFEjr1zCsicMWpAA")
    expect(token.token_type).to eq("Bearer")
    expect(token.expires_in).to eq(3600)
    expect(token.refresh_token).to eq("tGzv3JOkF0XG5Qx2TlKWIA")
    expect(token.extra_params).to eq("example_parameter" => "example_value")
  end
end
