# frozen_string_literal: false

require_relative File.join("..", "..", "..", "lib", "fix")

object = []

Fix { it MUST change(object, :length).by_at_most(1) }.against { object << 1 }

# test/matcher/change_observation/by_at_most_spec.rb:7 Success: expected [1] to change by at most 1.
