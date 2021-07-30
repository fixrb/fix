# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST equal(:foo) }.against { :foo }

# test/matcher/identity/equal_spec.rb:5 Success: expected to be :foo.
