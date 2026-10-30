# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "fix"
  spec.version                = File.read(File.join(__dir__, "VERSION.semver")).chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "Specifications in the words of RFC 2119, tested against a subject"
  spec.description            = "A specification says what a subject MUST, SHOULD or MAY do, and nothing about how " \
                                "it is made. Any subject is then tested against it, each context in a child " \
                                "process, and every expectation gets a result."
  spec.homepage               = "https://fixrb.dev/gems/fix/"
  spec.license                = "MIT"
  spec.files                  = Dir["LICENSE.md", "README.md", "lib/**/*.rb", base: __dir__]
  spec.required_ruby_version  = ">= 3.3.0"

  spec.metadata["bug_tracker_uri"]       = "https://github.com/fixrb/fix/issues"
  spec.metadata["documentation_uri"]     = "https://rubydoc.info/gems/fix"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.metadata["source_code_uri"]       = "https://github.com/fixrb/fix"

  spec.add_dependency "aw",      "~> 1.0"
  spec.add_dependency "defi",    "~> 4.0"
  spec.add_dependency "matchi",  "~> 6.0"
  spec.add_dependency "spectus", "~> 6.0"
end
