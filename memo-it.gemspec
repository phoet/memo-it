# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memo/it'

Gem::Specification.new do |spec|
  spec.name          = "memo-it"
  spec.version       = Memo::VERSION
  spec.authors       = ["phoet"]
  spec.email         = ["phoetmail@googlemail.com"]

  spec.summary       = %q{📥 📤 simple yet clever memoization helper with parameter support}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/phoet/memo-it"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "> 1.0"
  spec.add_development_dependency "rake", "> 10.0"
  spec.add_development_dependency "minitest", "> 5.0"
  spec.add_development_dependency "mocha"
end
