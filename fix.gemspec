# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = 'fix'
  spec.version                = File.read('VERSION.semver').chomp
  spec.author                 = 'Cyril Kato'
  spec.email                  = 'contact@cyril.email'
  spec.summary                = 'Specing framework for Ruby.'
  spec.description            = spec.summary
  spec.homepage               = 'https://fixrb.dev/'
  spec.metadata               = { 'source_code_uri' => 'https://github.com/fixrb/fix' }
  spec.license                = 'MIT'
  spec.required_ruby_version  = Gem::Requirement.new('>= 2.3.0')

  spec.files = Dir['LICENSE.md', 'README.md', 'lib/**/*']

  spec.add_dependency 'defi',     '~> 2.0.4'
  spec.add_dependency 'spectus',  '~> 3.1.2'

  spec.add_development_dependency 'bundler',              '~> 2.2'
  spec.add_development_dependency 'rake',                 '~> 13.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-rake'
  spec.add_development_dependency 'rubocop-thread_safety'


  spec.add_development_dependency 'simplecov',            '~> 0.21'
  spec.add_development_dependency 'yard',                 '~> 0.9'
end
