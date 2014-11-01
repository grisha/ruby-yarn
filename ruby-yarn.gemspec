# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-yarn/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-yarn"
  spec.version       = RubyYarn::VERSION
  spec.authors       = ["Grisha Trubetskoy"]
  spec.email         = ["grisha@apache.org"]
  spec.description   = %q{Yarn REST API Client}
  spec.summary       = %q{Yarn REST API Client}
  spec.homepage      = ""
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"
  spec.add_dependency "hashie"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
