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

module OAuth2c
  autoload :AccessToken,  "oauth2c/access_token"
  autoload :CLI,          "oauth2c/cli"
  autoload :Client,       "oauth2c/client"
  autoload :Error,        "oauth2c/error"
  autoload :Refinements,  "oauth2c/refinements"
  autoload :Strategies,   "oauth2c/strategies"
  autoload :ThreeLegged,  "oauth2c/three_legged"
  autoload :TwoLegged,    "oauth2c/two_legged"
  autoload :VERSION,      "oauth2c/version"
end
