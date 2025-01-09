# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                  = "fix"
  spec.version               = File.read("VERSION.semver").chomp
  spec.author                = "Cyril Kato"
  spec.email                 = "contact@cyril.email"
  spec.summary               = "Happy Path to Ruby Testing"

  spec.description           = <<~DESC
    Fix is a modern Ruby testing framework built around a key architectural principle: the complete separation between specifications and tests. It allows you to write pure specification documents that define expected behaviors, and then independently challenge any implementation against these specifications.
  DESC

  spec.homepage              = "https://fixrb.dev/"
  spec.license               = "MIT"
  spec.files                 = Dir["LICENSE.md", "README.md", "lib/**/*"]

  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/fixrb/fix/issues",
    "documentation_uri"     => "https://rubydoc.info/gems/fix",
    "homepage_uri"          => "https://fixrb.dev",
    "source_code_uri"       => "https://github.com/fixrb/fix",
    "rubygems_mfa_required" => "true"
  }

  spec.add_dependency "defi",     "~> 3.0.1"
  spec.add_dependency "matchi",   "~> 4.2.0"
  spec.add_dependency "spectus",  "~> 5.0.2"
end
