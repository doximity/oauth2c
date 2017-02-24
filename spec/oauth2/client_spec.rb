require "spec_helper"

RSpec.describe OAuth2::Client do
  it "has a version number" do
    expect(OAuth2::Client::VERSION).not_to be nil
  end
end
