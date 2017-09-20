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

RSpec.describe OAuth2c::Client do

  let(:required_args) { { token_url: "", client_id: "" } }

  it "accepts/passes :agent_options along to the agent" do
    agent_options = { auth_via_body: true }
    expect(OAuth2c::Agent).to receive(:new).
      with(hash_including(agent_options))
    client = described_class.new(agent_options: agent_options, **required_args)
    client.authorization_code(state: "foo")
  end
end
