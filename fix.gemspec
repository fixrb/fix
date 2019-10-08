# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'fix'
  spec.version       = File.read('VERSION.semver').chomp
  spec.authors       = ['Cyril Kato']
  spec.email         = ['contact@cyril.email']

  spec.summary       = 'Specing framework.'
  spec.description   = 'Specing framework for Ruby.'
  spec.homepage      = 'https://github.com/fixrb/fix'
  spec.license       = 'MIT'

  spec.files         =
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^test/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aw',                     '~> 0.1.6'
  spec.add_dependency 'defi',                   '~> 1.1.5'
  spec.add_dependency 'spectus',                '~> 3.0.9'

  spec.add_development_dependency 'bundler',              '~> 2.0'
  spec.add_development_dependency 'rake',                 '~> 13.0'
  spec.add_development_dependency 'rubocop',              '~> 0.75'
  spec.add_development_dependency 'rubocop-performance',  '~> 1.5'
  spec.add_development_dependency 'simplecov',            '~> 0.17'
  spec.add_development_dependency 'yard',                 '~> 0.9'
end
