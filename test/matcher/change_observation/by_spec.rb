# frozen_string_literal: false

require_relative File.join("..", "..", "..", "lib", "fix")

object = []

Fix { it MUST change(object, :length).by(1) }.against { object << 1 }

# test/matcher/change_observation/by_spec.rb:7 Success: expected [1] to change by 1.
