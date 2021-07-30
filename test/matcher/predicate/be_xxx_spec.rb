# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST be_empty }.test { [] }

# test/matcher/predicate/be_xxx_spec.rb:5 Success: expected [] to be empty.
