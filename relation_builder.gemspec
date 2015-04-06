# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'relation_builder/version'

Gem::Specification.new do |spec|
  spec.name          = "relation_builder"
  spec.version       = RelationBuilder::VERSION
  spec.authors       = ["Ivan Zabrovskiy"]
  spec.email         = ["loriowar@gmail.com"]
  spec.summary       = %q{This is a gem for easy build of nested relations through options of initialize}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/Loriowar/relation_builder"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 3.2"
  spec.add_dependency "activesupport", ">= 3.2"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
