# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'enum_attr/version'

Gem::Specification.new do |spec|
  spec.name          = 'enum_attr'
  spec.version       = EnumAttr::VERSION
  spec.authors       = %w(scorix)
  spec.email         = %w(scorix@liulishuo.com)
  spec.description   = %q{This is a gem for adding enum attributes to classes.}
  spec.summary       = %q{This is a gem for adding enum attributes to classes.}
  spec.homepage      = 'http://git.llsapp.com/backend/enum_attr'
  spec.license       = 'MIT'
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_dependency 'activesupport', '~> 4.0.0'
end
