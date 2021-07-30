# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST match(/^[^@]+@[^@]+$/) }.test { "bob@example.email" }

# test/matcher/regular_expressions/match_spec.rb:5 Success: expected "bob@example.email" to match /^[^@]+@[^@]+$/.
