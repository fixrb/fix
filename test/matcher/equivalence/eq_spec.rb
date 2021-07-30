# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST eq("foo") }.against { "foo" }

# test/matcher/equivalence/eq_spec.rb:5 Success: expected to eq "foo".
