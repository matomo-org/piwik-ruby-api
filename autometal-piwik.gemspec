# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'piwik/version'

Gem::Specification.new do |s|
  s.name          = "autometal-piwik"
  s.version       = Piwik::VERSION
  s.authors       = ["Achilles Charmpilas"]
  s.email         = ["ac@humbuckercode.co.uk"]
  s.description   = %q{A complete Ruby client for the Piwik API}
  s.summary       = %q{A complete Ruby client for the Piwik API}
  s.homepage      = "http://humbuckercode.co.uk/licks/gems/piwik/"
  s.license       = 'MIT'
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency('xml-simple')
  s.add_dependency('rest-client')
  s.add_dependency('activesupport','~> 4.0')
  s.add_development_dependency('rspec')
end
