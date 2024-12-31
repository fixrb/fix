# frozen_string_literal: true

require "matchi"

module Fix
  # Collection of expectation matchers.
  #
  # The following matchers are available:
  #
  # Basic Comparison:
  # - eq(expected)         # Checks equality using eql?
  # - eql(expected)        # Alias for eq
  # - be(expected)         # Checks exact object identity using equal?
  # - equal(expected)      # Alias for be
  #
  # Type Checking:
  # - be_an_instance_of(class) # Checks exact class match
  # - be_a_kind_of(class)      # Checks class inheritance and module inclusion
  #
  # State & Changes:
  # - change(object, method)     # Base for checking state changes
  #   .by(n)                     # Exact change by n
  #   .by_at_least(n)            # Minimum change by n
  #   .by_at_most(n)             # Maximum change by n
  #   .from(old).to(new)         # Change from old to new value
  #   .to(new)                   # Change to new value
  #
  # Value Testing:
  # - be_within(delta).of(value) # Checks numeric value within delta
  # - match(regex)               # Tests against regular expression
  # - satisfy { |value| ... }    # Custom matcher with block
  #
  # Exceptions:
  # - raise_exception(class)     # Checks if code raises exception
  #
  # State Testing:
  # - be_true                    # Tests for true
  # - be_false                   # Tests for false
  # - be_nil                     # Tests for nil
  #
  # Predicate Matchers:
  # - be_*                       # Matches object.*? method
  # - have_*                     # Matches object.has_*? method
  #
  # @api private
  module Matcher
    include Matchi
  end
end
