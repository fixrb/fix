# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST eql("foo") }.against { "foo" }

# test/matcher/equivalence/eql_spec.rb:5 Success: expected to eq "foo".
