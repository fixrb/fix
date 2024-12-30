# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "fix"
  spec.version                = File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "Specing framework."
  spec.description            = spec.summary
  spec.homepage               = "https://fixrb.dev/"
  spec.license                = "MIT"
  spec.files                  = Dir["LICENSE.md", "README.md", "lib/**/*"]

  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/fixrb/fix/issues",
    "documentation_uri"     => "https://rubydoc.info/gems/fix",
    "source_code_uri"       => "https://github.com/fixrb/fix",
    "wiki_uri"              => "https://github.com/fixrb/fix/wiki",
    "rubygems_mfa_required" => "true"
  }

  spec.add_dependency "defi",     "~> 3.0.0"
  spec.add_dependency "matchi",   "~> 4.0.0"
  spec.add_dependency "spectus",  "~> 5.0.1"
end
