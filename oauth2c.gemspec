# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oauth2c/version'

Gem::Specification.new do |spec|
  spec.name          = "oauth2c"
  spec.version       = OAuth2c::VERSION
  spec.authors       = ["Rodrigo Kochenburger"]
  spec.email         = ["divoxx@gmail.com"]

  spec.summary       = %q{OAuth2 client implementation with modular approach, allowing for custom strategies, and CLI tool}
  spec.description   = %q{OAuth2 client implementation with modular approach, allowing for custom strategies, and CLI tool}
  spec.homepage      = "https://github.com/doximity/oauth2c"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "http", "~> 2.0"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 2.0"
end
