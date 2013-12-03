# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shared_count_api/version'

Gem::Specification.new do |spec|
  spec.name          = "shared_count_api"
  spec.version       = SharedCountApi::VERSION
  spec.authors       = ["Cristian Rasch"]
  spec.email         = ["cristianrasch@gmail.com"]
  spec.description   = %q{Thin wrapper around the SharedCount API in vanilla Ruby}
  spec.summary       = %q{This library wraps the SharedCount API exposing its data through POROs (Plain Old Ruby Objects)}
  spec.homepage      = "https://github.com/wecodeio/shared_count_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0.8"
  spec.add_development_dependency "minitest-line", "~> 0.5.0"
  spec.add_development_dependency "webmock", "~> 1.16.0"
end
