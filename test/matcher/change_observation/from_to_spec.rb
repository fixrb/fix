# frozen_string_literal: false

require_relative File.join("..", "..", "..", "lib", "fix")

object = "foo"

Fix { it MUST change(object, :to_s).from("foo").to("FOO") }.against { object.upcase! }

# test/matcher/change_observation/from_to_spec.rb:7 Success: expected to change from "foo" to "FOO".
