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

  spec.required_ruby_version = ">= 2.3.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(bin|test|spec|features|vendor|tasks|tmp)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "http", "~> 4"
  spec.add_runtime_dependency "jwt", "~> 1.5"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "sdoc"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rexml"
end
