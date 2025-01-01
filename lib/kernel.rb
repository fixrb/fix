# frozen_string_literal: true

require_relative "fix/builder"

# Extension of the global Kernel module to provide the Fix method.
# This allows Fix to be called from anywhere in the application
# without explicit namespace qualification.
#
# @api public
module Kernel
  # rubocop:disable Naming/MethodName

  # This rule is disabled because Fix is intentionally capitalized to act as
  # both a namespace and a method name, following Ruby conventions for DSLs.

  # Defines a new test specification or creates an anonymous specification set.
  # When a name is provided, the specification is registered globally and can
  # be referenced later using Fix[name]. Anonymous specifications are executed
  # immediately and cannot be referenced later.
  #
  # @example Creating a named specification for later use
  #   Fix :Calculator do
  #     on(:add, 2, 3) do
  #       it MUST equal 5
  #     end
  #   end
  #
  #   # Later in the code:
  #   Fix[:Calculator].test { Calculator.new }
  #
  # @example Creating and immediately testing an anonymous specification
  #   Fix do
  #     it MUST be_positive
  #   end.test { 42 }
  #
  # @param name [String, Symbol, nil] The constant name for the specification
  # @yield The specification definition block
  # @yieldreturn [void]
  # @return [Fix::Set] A collection of specifications ready for testing
  #
  # @see Fix::Builder
  # @see Fix::Set
  # @see Fix::Dsl
  def Fix(name = nil, &)
    ::Fix::Builder.build(name, &)
  end

  # rubocop:enable Naming/MethodName
end
