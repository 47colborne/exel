# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exel/version'

Gem::Specification.new do |spec|
  spec.name          = 'exel'
  spec.version       = EXEL::VERSION
  spec.authors       = ['yroo']
  spec.email         = ['dev@yroo.com']
  spec.summary       = 'EXEL, the Elastic eXEcution Language'
  spec.description   = 'A DSL for defining jobs that can be run in a highly scalable manner'
  spec.homepage      = 'https://github.com/47colborne/exel'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'aws-sdk', '~> 2'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10'
  spec.add_development_dependency 'rspec', '~> 3'
  spec.add_development_dependency 'guard', '~> 2'
  spec.add_development_dependency 'guard-rspec', '~> 4'
  spec.add_development_dependency 'guard-rubocop', '~> 1'
  spec.add_development_dependency 'terminal-notifier', '~> 1'
  spec.add_development_dependency 'terminal-notifier-guard', '~> 1'
  spec.add_development_dependency 'rubocop', '~> 0'
  spec.add_development_dependency 'rubocop-rspec', '~> 1'
  spec.add_development_dependency 'rubocop-rspec-focused', '~> 0'
end
