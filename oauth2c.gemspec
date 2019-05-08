# coding: utf-8

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

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth2c/version'

Gem::Specification.new do |spec|
  spec.name          = "oauth2c"
  spec.version       = OAuth2c::VERSION
  spec.authors       = ["Doximity"]
  spec.email         = ["engineering@doximity.com"]

  spec.summary       = %q{OAuth2c is a extensible OAuth2 client implementation}
  spec.description   = %q{OAuth2c is a extensible OAuth2 client implementation}
  spec.homepage      = "https://github.com/doximity/oauth2c"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.required_ruby_version = ">= 2.3.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "http", "~> 4"
  spec.add_runtime_dependency "jwt", "~> 1.5"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
