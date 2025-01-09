# frozen_string_literal: true

# Extension of the global Kernel module to provide the Fix method.
# This module provides a global entry point to the Fix testing framework,
# allowing specifications to be defined and managed from anywhere in the application.
#
# The Fix method can be used in two main ways:
# 1. Creating named specifications for reuse
# 2. Creating anonymous specifications for immediate testing
#
# @api public
module Kernel
  # rubocop:disable Naming/MethodName

  # This rule is disabled because Fix is intentionally capitalized to act as
  # both a namespace and a method name, following Ruby conventions for DSLs.

  # Defines a new test specification or creates an anonymous specification.
  # When a name is provided, the specification is registered globally and can be
  # referenced later using Fix[name]. Anonymous specifications are executed
  # immediately and cannot be referenced later.
  #
  # Specifications can use three levels of requirements, following RFC 2119:
  # - MUST/MUST_NOT: Absolute requirements or prohibitions
  # - SHOULD/SHOULD_NOT: Strong recommendations that can be ignored with good reason
  # - MAY: Optional features that can be implemented or not
  #
  # Available matchers include:
  # - Basic Comparison: eq(expected), eql(expected), be(expected), equal(expected)
  # - Type Checking: be_an_instance_of(class), be_a_kind_of(class)
  # - State & Changes: change(object, method).by(n), by_at_least(n), by_at_most(n),
  #                   from(old).to(new), to(new)
  # - Value Testing: be_within(delta).of(value), match(regex),
  #                 satisfy { |value| ... }
  # - Exceptions: raise_exception(class)
  # - State Testing: be_true, be_false, be_nil
  #
  # @example Creating a named specification with multiple contexts and matchers
  #   Fix :Calculator do
  #     on(:add, 2, 3) do
  #       it MUST eq 5
  #       it MUST be_an_instance_of(Integer)
  #     end
  #
  #     with precision: :high do
  #       on(:divide, 10, 3) do
  #         it MUST be_within(0.001).of(3.333)
  #       end
  #     end
  #
  #     on(:divide, 1, 0) do
  #       it MUST raise_exception ZeroDivisionError
  #     end
  #   end
  #
  # @example Creating and immediately testing an anonymous specification
  #   Fix do
  #     it MUST be_positive
  #     it SHOULD be_even
  #     it MAY be_prime
  #   end.test { 42 }
  #
  # @example Testing state changes
  #   Fix :Account do
  #     on(:deposit, 100) do
  #       it MUST change(account, :balance).by(100)
  #       it SHOULD change(account, :updated_at)
  #     end
  #
  #     on(:withdraw, 50) do
  #       it MUST change(account, :balance).by(-50)
  #       it MUST_NOT change(account, :status)
  #     end
  #   end
  #
  # @param name [Symbol, nil] Optional name to register the specification under
  # @yield Block containing the specification definition using Fix DSL
  # @return [Fix::Spec] A specification ready for testing
  # @raise [Fix::Error::MissingSpecificationBlock] If no block is provided
  # @raise [Fix::Error::InvalidSpecificationName] If name is not a valid constant name
  #
  # @see Fix::Spec For managing and executing test specifications
  # @see Fix::Dsl For the domain-specific language used in specifications
  # @see Fix::Matcher For the complete list of available matchers
  # @see https://tools.ietf.org/html/rfc2119 For details about requirement levels
  #
  # @api public
  def Fix(name = nil, &block)
    ::Fix.spec(name, &block)
  end

  # rubocop:enable Naming/MethodName
end
