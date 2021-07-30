# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST be_within(2).of(42) }.against { 40 }

# test/matcher/comparisons/be_within_spec.rb:5 Success: expected 40 to be within 2 of 42.
