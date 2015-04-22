# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "exceptional_middleware/version"

Gem::Specification.new do |spec|
  spec.name          = "exceptional_middleware"
  spec.version       = ExceptionalMiddleware::VERSION
  spec.authors       = ["Danny Guinther"]
  spec.email         = ["dannyguinther@gmail.com"]
  spec.summary       = %q{Remote exception handling via a middleware chain.}
  spec.description   = %q{Remote exception handling via a middleware chain.}
  spec.homepage      = "https://github.com/tdg5/exceptional_middleware"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ["lib"]

  spec.add_dependency "remotely_exceptional"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 0"
end
