# frozen_string_literal: true

require_relative File.join("..", "..", "..", "lib", "fix")

Fix { it MUST have_key(:foo) }.test { { foo: 42 } }

# test/matcher/predicate/have_xxx_spec.rb:5 Success: expected {:foo=>42} to have key :foo.
