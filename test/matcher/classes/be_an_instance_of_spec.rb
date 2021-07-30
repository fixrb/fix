# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST be_an_instance_of Integer }.against { 42 }

# test/matcher/classes/be_an_instance_of_spec.rb:5 Success: expected 42 to be an instance of Integer.
