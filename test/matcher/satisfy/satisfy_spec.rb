# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST(satisfy { |value| value == 42 }) }.against { 42 }

# test/matcher/satisfy/satisfy_spec.rb:5 Success: expected 42 to satisfy &block.
