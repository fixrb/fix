# frozen_string_literal: true

require "matchi"

module Fix
  # Collection of expectation matchers.
  # Provides a comprehensive set of matchers for testing different aspects of objects.
  #
  # The following matchers are available:
  #
  # Basic Comparison:
  # - eq(expected)         # Checks equality using eql?
  #     it MUST eq(42)
  #     it MUST eq("hello")
  # - eql(expected)        # Alias for eq
  # - be(expected)         # Checks exact object identity using equal?
  #     string = "test"
  #     it MUST be(string)  # Passes only if it's the same object
  # - equal(expected)      # Alias for be
  #
  # Type Checking:
  # - be_an_instance_of(class) # Checks exact class match
  #     it MUST be_an_instance_of(Array)
  # - be_a_kind_of(class)      # Checks class inheritance and module inclusion
  #     it MUST be_a_kind_of(Enumerable)
  #
  # State & Changes:
  # - change(object, method)     # Base for checking state changes
  #   .by(n)                     # Exact change by n
  #     it MUST change(user, :points).by(5)
  #   .by_at_least(n)            # Minimum change by n
  #     it MUST change(counter, :value).by_at_least(10)
  #   .by_at_most(n)             # Maximum change by n
  #     it MUST change(account, :balance).by_at_most(100)
  #   .from(old).to(new)         # Change from old to new value
  #     it MUST change(user, :status).from("pending").to("active")
  #   .to(new)                   # Change to new value
  #     it MUST change(post, :title).to("Updated")
  #
  # Value Testing:
  # - be_within(delta).of(value) # Checks numeric value within delta
  #     it MUST be_within(0.1).of(3.14)
  # - match(regex)               # Tests against regular expression
  #     it MUST match(/^\d{3}-\d{2}-\d{4}$/)  # SSN format
  # - satisfy { |value| ... }    # Custom matcher with block
  #     it MUST satisfy { |num| num.even? && num > 0 }
  #
  # Exceptions:
  # - raise_exception(class)     # Checks if code raises exception
  #     it MUST raise_exception(ArgumentError)
  #     it MUST raise_exception(CustomError, "specific message")
  #
  # State Testing:
  # - be_true                    # Tests for true
  #     it MUST be_true          # Only passes for true, not truthy values
  # - be_false                   # Tests for false
  #     it MUST be_false         # Only passes for false, not falsey values
  # - be_nil                     # Tests for nil
  #     it MUST be_nil
  #
  # Predicate Matchers:
  # - be_*                       # Matches object.*? method
  #     it MUST be_empty         # Calls empty?
  #     it MUST be_valid         # Calls valid?
  #     it MUST be_frozen        # Calls frozen?
  # - have_*                     # Matches object.has_*? method
  #     it MUST have_key(:id)    # Calls has_key?
  #     it MUST have_errors      # Calls has_errors?
  #
  # @note All matchers can be used with MUST, MUST_NOT, SHOULD, SHOULD_NOT, and MAY
  # @see https://github.com/fixrb/matchi for more details about the matchers
  # @api private
  module Matcher
    include Matchi
  end
end
