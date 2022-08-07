# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST be(:foo) }.test { :foo }

# test/matcher/identity/be_spec.rb:5 Success: expected to be :foo.
