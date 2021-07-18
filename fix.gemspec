# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "fix"
  spec.version                = File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "Specing framework for Ruby."
  spec.description            = spec.summary
  spec.homepage               = "https://fixrb.dev/"
  spec.license                = "MIT"
  spec.required_ruby_version  = Gem::Requirement.new(">= 2.7.0")
  spec.files                  = Dir["LICENSE.md", "README.md", "lib/**/*"]

  spec.metadata = {
    "bug_tracker_uri"   => "https://github.com/fixrb/fix/issues",
    "documentation_uri" => "https://rubydoc.info/gems/r_spec-clone",
    "source_code_uri"   => "https://github.com/fixrb/fix",
    "wiki_uri"          => "https://github.com/fixrb/fix/wiki"
  }

  spec.add_dependency "defi",     "~> 2.0.5"
  spec.add_dependency "matchi",   "~> 2.2.0"
  spec.add_dependency "spectus",  "~> 4.0.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rubocop-md"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "rubocop-thread_safety"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "yard"
end
