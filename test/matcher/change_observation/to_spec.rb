# frozen_string_literal: false

require_relative File.join("..", "..", "..", "lib", "fix")

object = "foo"

Fix { it MUST change(object, :to_s).to("FOO") }.against { object.upcase! }

# test/matcher/change_observation/to_spec.rb:7 Success: expected to change to "FOO".
