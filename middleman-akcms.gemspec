# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'middleman-akcms/version'

Gem::Specification.new do |spec|
  spec.name          = "middleman-akcms"
  spec.version       = Middleman::Akcms::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Ataru Kodaka"]
  spec.email         = ["ataru.kodaka@gmail.com"]
  spec.summary       = %q{A template of Middleman to manage Markdown files efficientrly}
  spec.description   = %q{A template of Middleman to manage Markdown files efficientrly.}
  spec.homepage      = "https://github.com/atarukodaka/middleman-aks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.0.0'


  spec.add_dependency("middleman", ">= 4.0")
  spec.add_dependency("oga", ">= 2.0")
end
